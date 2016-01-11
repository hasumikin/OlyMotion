class SettingsViewController < UIViewController

  include UIViewControllerThreading
  include DebugConcern

  attr_accessor :bluetoothConnector, :wifiConnector, :showWifiSettingCell, :table

  def viewDidLoad
    super

    # ビューコントローラーの活動状態を初期化します。
    @startingActivity = false

    # 現在位置利用の権限確認を準備します。
    @locationManager = CLLocationManager.new
    @locationManager.delegate = self

    # アプリケーションの実行状態を監視開始します。
    notificationCenter = NSNotificationCenter.defaultCenter
    notificationCenter.addObserver(self, selector:'applicationDidBecomeActive:', name:'UIApplicationDidBecomeActiveNotification', object:nil)
    notificationCenter.addObserver(self, selector:'applicationWillResignActive:', name:'UIApplicationWillResignActiveNotification', object:nil)
    notificationCenter.addObserver(self, selector:'applicationDidEnterBackground:', name:'UIApplicationDidEnterBackgroundNotification', object:nil)
    notificationCenter.addObserver(self, selector:'applicationWillEnterForeground:', name:'UIApplicationWillEnterForegroundNotification', object:nil)

    # アプリケーション設定の変更を監視準備します。
    notificationCenter.addObserver(self, selector:'didChangedAppSetting:', name:'AppSettingChangedNotification', object:nil)

    appDelegate = UIApplication.sharedApplication.delegate
    @camera = AppCamera.instance#appDelegate.camera#
    @setting = AppSetting.instance#appDelegate.setting

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self

    @table_data = [
      { title: 'Access Method',
        rows: [
          { label: 'Bluetooth',
            detail: '$bluetoothLocalName',
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            outlet: :@showBluetoothSettingCell
          },
          { label: 'Wi-Fi',
            detail: '$ssid',
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            outlet: :@showWifiSettingCell
          }
        ]
      },
      { title: 'Connection',
        rows: [
          { label: 'Connect with Bluetooth',
            detail: '',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@connectWithUsingBluetoothCell
          },
          { label: 'Connect with Wi-Fi',
            detail: '',
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            outlet: :@connectWithUsingWifiCell
          },
          { label: 'Disconnect',
            detail: '',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@disconnectCell
          },
          { label: 'Disconnect and Sleep',
            detail: '',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@disconnectAndSleepCell
          }
        ]
      }
    ]

    Motion::Layout.new do |layout|
      layout.view self.view
      layout.subviews table: @table
      layout.vertical "|[table]|"
      layout.horizontal "|[table]|"
    end

    # Wi-Fiの接続状態を監視するインスタンス
    @wifiConnector = WifiConnector.new
    notificationCenter.addObserver(self, selector:'didChangeWifiStatus:', name:WifiConnector::WifiStatusChangedNotification, object:nil)
    # Bluetoothの接続状態を監視するインスタンス
    @bluetoothConnector = BluetoothConnector.new
    notificationCenter.addObserver(self, selector:'didChangeBluetoothConnection:', name:BluetoothConnector::BluetoothConnectionChangedNotification, object:nil)
  end

  def viewDidAppear(animated)
    super(animated)

    unless @startingActivity
      # MARK: iOS9では初回の画面表示の際にapplicationDidBecomeActiveが呼び出されないのでここでフォローします。
      # todo: バージョン判定のRubymotion的書き方がわからないので常に実行。そのうち直す
      # if NSProcessInfo.processInfo.isOperatingSystemAtLeastVersion('9.0')
      # dp "The application is running on iOS9!"
      applicationDidBecomeActive(nil)
      # end
      @startingActivity = true
    end
  end

  # アプリケーションがアクティブになる時に呼び出されます。
  def applicationDidBecomeActive(notification)
    # 写真アルバム利用の権限があるか確認します。
    case ALAssetsLibrary.authorizationStatus
    when ALAuthorizationStatusNotDetermined
      dp "Using assets library isn't determind."
      assetsLibraryRequestWhenInUseAuthorization
    when ALAuthorizationStatusAuthorized
      dp "Using assets library is already authorized."
    when ALAuthorizationStatusDenied
    when ALAuthorizationStatusRestricted
      dp "Using assets library is restricted."
    end

    # 現在位置利用の権限があるかを確認します。
    case CLLocationManager.authorizationStatus
    when KCLAuthorizationStatusNotDetermined # 最初のkを大文字にするRM
      dp "Using location service isn't determind."
      @locationManager.requestWhenInUseAuthorization
    when KCLAuthorizationStatusAuthorizedAlways
    when KCLAuthorizationStatusAuthorizedWhenInUse
      dp "Using location service is already authorized."
    when KCLAuthorizationStatusDenied
    when KCLAuthorizationStatusRestricted
      dp "Using location service is restricted."
    end

    # Wi-Fiの接続監視を開始
    @wifiConnector.startMonitoring
    # 画面を更新
    updateShowWifiSettingCell
    updateShowBluetoothSettingCell
    updateCameraConnectionCells
    # updateCameraOperationCells
  end

  # アプリケーションが非アクティブになる時に呼び出されます。
  def applicationWillResignActive(notification)
    # 強制的に、カメラとのアプリ接続を解除します。
    error = Pointer.new(:object)
    if @camera.disconnectWithPowerOff(false, error:error)
      dp "カメラとのアプリ接続解除に失敗しました。"
      dp "エラーを無視して続行します。"
    end

    # 強制的に、カメラとのBluetooth接続を解除します。
    @camera.bluetoothPeripheral = nil
    @camera.bluetoothPassword = nil
    unless @bluetoothConnector.disconnectPeripheral(error)
      dp "カメラとのBluetooth接続解除に失敗しました。"
      dp "エラーを無視して続行します。"
    end

    # Bluetoothの接続状態を監視停止
    @bluetoothConnector.peripheral = nil
    # Wi-Fiの接続監視を停止
    @wifiConnector.stopMonitoring

    # @TODO
    # // カメラ操作の子画面を表示している場合は、この画面に戻します。
    # [self backToConnectionView:NO];
  end

  # アプリケーションがバックグラウンドに入る時に呼び出されます。
  def applicationDidEnterBackground(notification)
    # TODO: このタイミングはカメラ接続を一時停止するために研究の余地があります。
  end

  # アプリケーションがフォアグラウンドに入る時に呼び出されます。
  def applicationWillEnterForeground(notification)
    # TODO: このタイミングはカメラ接続を復旧するために研究の余地があります。
  end

  #
  # 以上基礎実装
  #
  # 以下固有実装
  #

  # 現在位置利用の権限が変化した時に呼び出されます。
  def locationManager(manager, didChangeAuthorizationStatus:status)
    case CLLocationManager.authorizationStatus
    when KCLAuthorizationStatusNotDetermined
      dp "Using location service isn't determind."
    when KCLAuthorizationStatusAuthorizedAlways
    when KCLAuthorizationStatusAuthorizedWhenInUse
      dp "Using location service is already authorized."
    when KCLAuthorizationStatusDenied
    when KCLAuthorizationStatusRestricted
      dp "Using location service is restricted."
    end
  end

  # 写真アルバムの利用してよいか問い合わせます。
  def assetsLibraryRequestWhenInUseAuthorization
    library = ALAssetsLibrary.new
    library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock:lambda do |group, stop|
      break unless group
      dp "group=#{group.valueForProperty(ALAssetsGroupPropertyName)}"
    end, failureBlock:lambda do |error|
      dp "error=#{error.localizedDescription}"
    end)
  end

  # Wi-Fi接続の状態が変化した時に呼び出されます。
  def didChangeWifiStatus(notification)
    # メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
    unless NSThread.isMainThread
      weakSelf = WeakRef.new(self)
      # weakSelf.executeAsynchronousBlockOnMainThread -> {
      Dispatch::Queue.main.async {
        dp "weakSelf=#{weakSelf}"
        weakSelf.didChangeWifiStatus(notification)
      }
    else
      # 画面表示を更新します。
      updateShowWifiSettingCell
      updateShowBluetoothSettingCell
      updateCameraConnectionCells
      # updateCameraOperationCells
    end
  end

  # Bluetooth接続の状態が変化した時に呼び出されます。
  def didChangeBluetoothConnection(notification)
    # メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
    unless NSThread.isMainThread
      weakSelf = WeakRef.new(self)
      # weakSelf.executeAsynchronousBlockOnMainThread:^{
      Dispatch::Queue.main.async {
        dp "weakSelf=#{weakSelf}"
        weakSelf.didChangeBluetoothConnection(notification)
      }
      return
    end

    # MARK: カメラキットはBluetoothの切断を検知しないのでアプリが自主的にカメラとの接続を解除しなければならない。
    if @camera.connected && @camera.connectionType == OLYCameraConnectionTypeBluetoothLE
      bluetoothStatus = @bluetoothConnector.connectionStatus
      if bluetoothStatus == 'BluetoothConnectionStatusNotFound' || bluetoothStatus == 'BluetoothConnectionStatusNotConnected'
        # カメラとのアプリ接続を解除します。
        error = Pointer.new(:object)
        unless @camera.disconnectWithPowerOff(false, error:error)
          # カメラのアプリ接続を解除できませんでした。
          # エラーを無視して続行します。
          dp "An error occurred, but ignores it."
        end

        # カメラとのBluetooth接続を解除します。
        @camera.bluetoothPeripheral = nil
        @camera.bluetoothPassword = nil
      end
    end

    # 画面表示を更新します。
    updateShowBluetoothSettingCell
    updateCameraConnectionCells
    # self.updateCameraOperationCells

    # カメラ操作の子画面を表示している場合は、この画面に戻します。
    # self.backToConnectionView(true)
  end

  # ひとつひとつのセルのenableをスイッチ
  # def updateCell(outlet, enable, accessoryType = nil)
  #   if @table
  #     dp "tableView!!!!! #{outlet}"
  #     dp "enable=#{enable}"
  #     dp "accessoryType=#{accessoryType}"
  #     section_index = nil
  #     row_index = nil
  #     @table_data.each_with_index do |section, index|
  #       if row_index = section[:rows].index{|row| row[:outlet] == outlet}
  #         section_index = index
  #         break
  #       end
  #     end
  #   else
  #     dp "tableView??????? #{outlet}"
  #   end
  #   if row_index && section_index
  #     indexPath = NSIndexPath.indexPathForRow(row_index, inSection:section_index)
  #     cell = @table.cellForRowAtIndexPath(indexPath)
  def updateCell(cell, enable, accessoryType = nil)
      if @table && cell
        cell.userInteractionEnabled  = enable unless enable.nil?
        cell.textLabel.enabled       = enable unless enable.nil?
        cell.detailTextLabel.enabled = enable unless enable.nil?
        cell.accessoryType    = accessoryType if accessoryType
      else
        dp "cellがnil？"
      end
    end
  # end

  # アプリ接続の状態を画面に表示します。
  def updateCameraConnectionCells
    if @camera.connected && @camera.connectionType == OLYCameraConnectionTypeBluetoothLE
      dp "Bluetoothで接続中です。"
      updateCell(@connectWithUsingBluetoothCell, false, UITableViewCellAccessoryCheckmark)
      updateCell(@connectWithUsingWiFiCell, false, UITableViewCellAccessoryNone)
      updateCell(@disconnectCell, true)
      updateCell(@disconnectAndSleepCell, true)
    elsif @camera.connected && @camera.connectionType == OLYCameraConnectionTypeWiFi
      dp "Wi-Fiで接続中です。"
      updateCell(@connectWithUsingBluetoothCell, false, UITableViewCellAccessoryNone)
      updateCell(@connectWithUsingWiFiCell, false, UITableViewCellAccessoryCheckmark)
      updateCell(@disconnectCell, true)
      updateCell(@disconnectAndSleepCell, true)
    else
      dp "未接続です。"
      if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
        dp "Bluetooth使用可"
        updateCell(@connectWithUsingBluetoothCell, true)
      else
        dp "Bluetooth使用不可"
        updateCell(@connectWithUsingBluetoothCell, false)
      end
      if @wifiConnector.connectionStatus == 'WifiConnectionStatusConnected'
        if @wifiConnector.cameraStatus == 'WifiCameraStatusReachable'
          dp "Wi-Fi接続済みで接続先はカメラ"
          updateCell(@connectWithUsingWiFiCell, true)
        elsif @wifiConnector.cameraStatus == 'WifiCameraStatusUnreachable'
          dp "Wi-Fi接続済みで接続先はカメラではない"
          if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
            dp "Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし"
            dp "だが、カメラの電源を入れることぐらいはできるかもしれない"
            updateCell(@connectWithUsingWiFiCell, true)
          else
            dp "Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし"
            updateCell(@connectWithUsingWiFiCell, false)
          end
        else
          dp "Wi-Fi接続済みで接続先は確認中"
          dp "カメラにアクセスできるか否かが確定するまでの間は操作を許可しない"
          updateCell(@connectWithUsingWiFiCell, false)
        end
      else
        if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
          dp "Wi-Fi未接続でBluetooth経由の電源投入により自動接続できる見込みあり"
          updateCell(@connectWithUsingWiFiCell, true)
        else
          dp "Wi-Fi未接続でBluetooth使用不可なため自動でカメラに接続できる見込みなし"
          updateCell(@connectWithUsingWiFiCell, false)
        end
      end
      updateCell(@disconnectCell, false)
      updateCell(@disconnectAndSleepCell, false)
      updateCell(@connectWithUsingBluetoothCell, nil, UITableViewCellAccessoryNone)
      updateCell(@connectWithUsingWiFiCell, nil, UITableViewCellAccessoryNone)
    end
  end


  # Wi-Fi接続の状態を表示します。
  def updateShowWifiSettingCell
    return nil unless @showWifiSettingCell
    wifiStatus = @wifiConnector.connectionStatus
    @showWifiSettingCell.detailTextLabel.text = if wifiStatus == 'WifiConnectionStatusConnected'
      # 接続されている場合はそのSSIDを表示します。
      cameraStatus = @wifiConnector.cameraStatus
      if cameraStatus == 'WifiCameraStatusReachable'
        @wifiConnector.ssid ? @wifiConnector.ssid : "WifiConnected(null)"
      elsif cameraStatus == 'WifiCameraStatusUnreachable1'
        @wifiConnector.ssid ? "WifiNotConnected1(#{@wifiConnector.ssid})" : "WifiNotConnected1(null)"
      elsif cameraStatus == 'WifiCameraStatusUnreachable2'
        @wifiConnector.ssid ? "WifiNotConnected2(#{@wifiConnector.ssid})" : "WifiNotConnected2(null)"
      else
        "WifiStatusUnknown1" # Wi-Fi接続済みで接続先は確認中
      end
    elsif wifiStatus == 'WifiConnectionStatusNotConnected'
      "WifiNotConnected"
    else
      "WifiStatusUnknown2"
    end
    @showWifiSettingCell.userInteractionEnabled = true
  end

  def updateShowBluetoothSettingCell
    @showBluetoothSettingCell.detailTextLabel.text = @setting['bluetoothLocalName'] if @showBluetoothSettingCell
  end

  def viewWillAppear(animated)
    super
    navigationController.setToolbarHidden(true, animated:animated)
  end

  # dataSource = self に必須のメソッド1/2
  def tableView(tableView, numberOfRowsInSection: section)
    @table_data[section][:rows].size
  end

  # dataSource = self に必須のメソッド2/2
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end
    # ↑ここまではお決まりのコード
    # ↓ここでテーブルにデータを入れる
    row = @table_data[indexPath.section][:rows][indexPath.row]
    instance_variable_set(row[:outlet], cell) if row[:outlet]
    cell.textLabel.text       = row[:label]
    cell.detailTextLabel.text = row[:detail]
    cell.accessoryType        = row[:accessory_type]
    # ↓セルを返す。本メソッドの末尾にこれが必須
    cell
  end

  #セクションの数
  def numberOfSectionsInTableView(tableView)
    @table_data.size
  end

  # セクションのタイトル
  def tableView(tableView, titleForHeaderInSection: section)
    @table_data[section][:title]
  end

  # テーブルの行がタップされた
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    outlet = @table_data[indexPath.section][:rows][indexPath.row][:outlet]
    case outlet
    when :@showWifiSettingCell
      openWifiConfig
    when :@showBluetoothSettingCell
      BluetoothViewController.new.tap do |controller|
        self.navigationController.pushViewController(controller, animated:true)
      end
    when :@connectWithUsingBluetoothCellCell
      didSelectRowAtConnectWithUsingBluetoothCell
    when :@connectWithUsingWifiCell
      if @camera.connected
        PhotoViewController.new.tap do |controller|
          self.navigationController.pushViewController(controller, animated:true)
        end
      else
        didSelectRowAtConnectWithUsingWifiCell
      end
    when :@disconnectCell
      didSelectRowAtDisconnectCell
    when :@disconnectAndSleepCell
      didSelectRowAtDisconnectAndSleepCell
    end
  end

  # 'Connect with using Wi-Fi'のセルが選択されたときに呼び出されます。
  def didSelectRowAtConnectWithUsingWifiCell
    # カメラへの接続するのに電源投入も必要か否かを調べます。
    demandToWakeUpWithUsingBluetooth = false
    if @wifiConnector.connectionStatus == 'WifiConnectionStatusConnected'
      if @wifiConnector.cameraStatus == 'WifiCameraStatusReachable'
        # App.alert "2"
        # Wi-Fi接続済みで接続先はカメラ
      elsif @wifiConnector.cameraStatus == 'WifiCameraStatusUnreachable'
        # Wi-Fi接続済みで接続先はカメラではない
        if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
          # Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし
          # だが、カメラの電源を入れることぐらいはできるかもしれない
          # App.alert "3"
          demandToWakeUpWithUsingBluetooth = true
        else
          # Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし
          App.alert "WifiConnectionIsNotCamera"
          return
        end
      else
        # Wi-Fi接続済みで接続先は確認中
        # TODO: どうすればよい?
      end
    else
      if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
        # Wi-Fi未接続でBluetooth経由の電源投入により自動接続できる見込みあり
        # App.alert "4"
        demandToWakeUpWithUsingBluetooth = true
      else
        # Wi-Fi未接続でBluetooth使用不可なため自動でカメラに接続できる見込みなし
        App.alert "NoWifiConnections"
        return
      end
    end

    # Bluetoothデバイスの設定を確認します。
    bluetoothLocalName = @setting['bluetoothLocalName']
    bluetoothPasscode = @setting['bluetoothPasscode']
    if demandToWakeUpWithUsingBluetooth
      if !bluetoothLocalName || bluetoothLocalName.length == 0
        # Bluetoothデバイスの設定が不完全です。
        App.alert "CouldNotConnectBluetoothByEmptySetting"
        return
      end
    end

    # # カメラの電源を投入し接続を開始します。
    # # 作者の環境ではiPhone 4Sだと電源投入から接続確率まで20秒近くかかっています。
    weakSelf = WeakRef.new(self)
    weakSelf.bluetoothConnector.services = OLYCamera.bluetoothServices
    weakSelf.bluetoothConnector.localName = bluetoothLocalName
    dp '接続開始'
    weakSelf.showProgressWhileExecutingBlock(true) do |progressView|
      dp "weakSelf=#{weakSelf}"
      dp "demandToWakeUpWithUsingBluetooth=#{demandToWakeUpWithUsingBluetooth}"

      # カメラに電源投入を試みます。
      if demandToWakeUpWithUsingBluetooth
        # カメラを探します。
        error_ptr = Pointer.new(:object)
        if weakSelf.bluetoothConnector.connectionStatus == 'BluetoothConnectionStatusNotFound'
          unless weakSelf.bluetoothConnector.discoverPeripheral(error_ptr)
            # カメラが見つかりませんでした。
            error = error_ptr[0]
            weakSelf.alertOnMainThreadWithMessage(error.localizedDescription, title: "CouldNotConnectWifi6")
            openWifiConfig
            next #【注】 Obj-c版では`return`と書いているが、rubyではnext
          end
        end

        # カメラにBluetooth接続します。
        if weakSelf.bluetoothConnector.connectionStatus == 'BluetoothConnectionStatusNotConnected'
          unless weakSelf.bluetoothConnector.connectPeripheral(error_ptr)
            # カメラにBluetooth接続できませんでした。
            error = error_ptr[0]
            weakSelf.alertOnMainThreadWithMessage(error.localizedDescription, title: "CouldNotConnectWifi7")
            openWifiConfig
            next #【注】 Obj-c版では`return`と書いているが、rubyではnext
          end
        end

        # カメラの電源を入れます。
        # MARK: カメラ本体のLEDはすぐに電源オン(青)になるが、この応答が返ってくるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
        # 作者の環境ではiPhone 4Sだと10秒程度かかっています。
        # MARK: カメラがUSB経由で給電中だと、wekeupメソッドはタイムアウトエラーが時々発生してしまうようです。
        weakSelf.reportBlockWakingUp(progressView)
        @camera.bluetoothPeripheral = weakSelf.bluetoothConnector.peripheral
        @camera.bluetoothPassword = bluetoothPasscode
        @camera.bluetoothPrepareForRecordingWhenPowerOn = true
        wokenUp = @camera.wakeup(error_ptr)
        unless wokenUp
          dp "カメラの電源を入れるのに失敗しました。"
          error = error_ptr[0]
          if error.domain == OLYCameraErrorDomain && error.code == OLYCameraErrorOperationAborted
            # MARK: カメラをUSB給電中に電源入れるとその後にWi-Fi接続できるようになるのにもかかわらずエラーが返ってくるようです。
            #     Error {
            #         Domain = OLYCameraErrorDomain
            #         Code = 195887114 (OLYCameraErrorOperationAborted)
            #         UserInfo = { NSLocalizedDescription=The camera did not respond in time. }
            #     }
            # エラーにすると使い勝手が悪いので、無視して続行します。
            dp "An error occurred, but ignore it."
            wokenUp = true
          else
            weakSelf.alertOnMainThreadWithMessage(error.localizedDescription, title: "CouldNotConnectWifi8")
          end
          openWifiConfig
        end
        @camera.bluetoothPeripheral = nil
        @camera.bluetoothPassword = nil

        # カメラとのBluetooth接続を解除します。
        # MARK: このタイミングで切断することによって、果たしてWi-FiとBluetoothの電波干渉を避けることができるか?
        unless weakSelf.bluetoothConnector.disconnectPeripheral(error_ptr)
          dp "カメラとのBluetooth接続解除に失敗しました。"
          dp "エラーを無視して続行します。"
        end
        weakSelf.bluetoothConnector.peripheral = nil

        # # カメラの電源を入れるのに失敗している場合はここで諦めます。
        next unless wokenUp #【注】 Obj-c版では`return`と書いているが、rubyではnext
        # # カメラの電源を入れた後にカメラにアクセスできるWi-Fi接続が有効になるまで待ちます。
        # # MARK: カメラ本体のLEDはすぐに接続中(緑)になるが、iOS側のWi-Fi接続が有効になるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
        # # 作者の環境ではiPhone 4Sだと10秒程度かかっています。
        weakSelf.reportBlockConnectingWifi(progressView)
        Dispatch::Queue.main.async {
          weakSelf.showWifiSettingCell.detailTextLabel.text = "ConnectingWifi"
        }
        unless weakSelf.wifiConnector.waitForConnected(20.0)
          # Connecting... を元に戻します。
          Dispatch::Queue.main.async {
            weakSelf.updateShowWifiSettingCell
          }
          # Wi-Fi接続が有効になりませんでした。
          if weakSelf.wifiConnector.connectionStatus != 'WifiConnectionStatusConnected'
            # カメラにアクセスできるWi-Fi接続は見つかりませんでした。
            weakSelf.alertOnMainThreadWithMessage("CouldNotDiscoverWifiConnection", title:"CouldNotConnectWifi1")
          else
            # カメラにアクセスできるWi-Fi接続ではありませんでした。(すでに別のアクセスポイントに接続している)
            weakSelf.alertOnMainThreadWithMessage("WifiConnectionIsNotCamera", title:"CouldNotConnectWifi2")
          end
          openWifiConfig
          next #【注】 Obj-c版では`return`と書いているが、rubyではnext
        end

        # # 電源投入が完了しました。
        progressView.mode = MBProgressHUDModeIndeterminate
        dp "To wake the camera up is success."
      end

      dp "カメラにアプリ接続します。"
      error_ptr = Pointer.new(:object)
      unless @camera.connect(OLYCameraConnectionTypeWiFi, error:error_ptr)
        dp "カメラにアプリ接続できませんでした。"
        error = error_ptr[0]
        weakSelf.alertOnMainThreadWithMessage(error.localizedDescription, title:"CouldNotConnectWifi3")
        openWifiConfig
        next #【注】 Obj-c版では`return`と書いているが、rubyではnext
      end

      dp "スマホの現在時刻をカメラに設定します。"
      # MARK: 保守モードでは受け付けないのでこのタイミングしかありません。
      unless @camera.changeTime(Time.now, error:error_ptr)
        dp "時刻が設定できませんでした。"
        error = error_ptr[0]
        weakSelf.alertOnMainThreadWithMessage(error.localizedDescription, title:"CouldNotConnectWifi4")
        openWifiConfig
        next #【注】 Obj-c版では`return`と書いているが、rubyではnext
      end

      # MARK: 実行モードがスタンドアロンモードのまま放置するとカメラの自動スリープが働いてしまってスタンドアロンモード以外へ変更できなくなってしまうようです。
      dp "カメラの自動スリープを防止するため、あらかじめ実行モードをスタンドアロンモード以外に変更しておきます。(取り敢えず保守モードへ)"
      unless @camera.changeRunMode(OLYCameraRunModeMaintenance, error:error_ptr)
        dp "実行モードを変更できませんでした。"
        error = error_ptr[0]
        weakSelf.alertOnMainThreadWithMessage(error.localizedDescription, title:"CouldNotConnectWifi5")
        openWifiConfig
        next #【注】 Obj-c版では`return`と書いているが、rubyではnext
      end

      dp "画面表示を更新します。"
      Dispatch::Queue.main.async {
        weakSelf.updateShowWifiSettingCell
        weakSelf.updateShowBluetoothSettingCell
        weakSelf.updateCameraConnectionCells
        dp "weakSelf.updateCameraOperationCells"
        dp "weakSelf.table.scrollToRowAtIndexPath(weakSelf.visibleWhenConnected, atScrollPosition:UITableViewScrollPositionMiddle, animated:true)"
      }

      dp "アプリ接続が完了しました。"
      weakSelf.reportBlockFinishedToProgress(progressView)
      dp "接続完了"
    end
  end

  # 'Disconnect'のセルが選択されたときに呼び出されます。
  def didSelectRowAtDisconnectCell
    dp "カメラの接続解除を開始します。"
    weakSelf = WeakRef.new(self)
    weakSelf.showProgressWhileExecutingBlock(true) do |progressView|
      dp "weakSelf=#{weakSelf}"

      dp "画面表示を更新します。"
      # Dispatch::Queue.main.async {
      #   weakSelf.table.scrollToRowAtIndexPath(weakSelf.visibleWhenDisconnected, atScrollPosition:UITableViewScrollPositionMiddle, animated:true)
      # }

      dp "カメラとのアプリ接続を解除します。"
      lastConnectionType = @camera.connectionType
      error = Pointer.new(:object)
      unless @camera.disconnectWithPowerOff(false, error:error)
        dp "カメラのアプリ接続を解除できませんでした。"
        dp "エラーを無視して続行します。"
        dp "An error occurred, but ignores it."
      end
      @camera.bluetoothPeripheral = nil
      @camera.bluetoothPassword = nil

      dp "カメラとのBluetooth接続を解除します。"
      if lastConnectionType == OLYCameraConnectionTypeBluetoothLE
        unless weakSelf.bluetoothConnector.disconnectPeripheral(error)
          dp "カメラのBluetooth接続を解除できませんでした。"
          dp "エラーを無視して続行します。"
          dp "An error occurred, but ignores it."
        end
        weakSelf.bluetoothConnector.peripheral = nil
      end

      dp "画面表示を更新します。"
      Dispatch::Queue.main.async {
        weakSelf.updateShowBluetoothSettingCell
        weakSelf.updateShowWifiSettingCell
        weakSelf.updateCameraConnectionCells
        # weakSelf.updateCameraOperationCells
      }

      dp "カメラの接続解除が完了しました。"
      weakSelf.reportBlockFinishedToProgress(progressView)
      dp ""
    end
  end

  #  'Disconnect and Sleep'のセルが選択されたときに呼び出されます。
  def didSelectRowAtDisconnectAndSleepCell
    dp "カメラの接続解除を開始します。"
    weakSelf = WeakRef.new(self)
    weakSelf.showProgressWhileExecutingBlock(true) do |progressView|
      dp "weakSelf=#{weakSelf}"

      # dp "画面表示を更新します。"
      # [weakSelf executeAsynchronousBlockOnMainThread:^{
      #   [weakSelf.table scrollToRowAtIndexPath:weakSelf.visibleWhenSleeped atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
      # }];

      dp "カメラとのアプリ接続を解除し電源を切ります。"
      lastConnectionType = @camera.connectionType
      error = Pointer.new(:object)
      unless @camera.disconnectWithPowerOff(true, error:error)
        dp "カメラのアプリ接続を解除できませんでした。"
        dp "エラーを無視して続行します。"
        dp "An error occurred, but ignores it."
      end
      @camera.bluetoothPeripheral = nil
      @camera.bluetoothPassword = nil

      dp "カメラとのBluetooth接続を解除します。"
      if lastConnectionType == OLYCameraConnectionTypeBluetoothLE
        unless weakSelf.bluetoothConnector.disconnectPeripheral(error)
          dp "カメラのBluetooth接続を解除できませんでした。"
          dp "エラーを無視して続行します。"
          dp "An error occurred, but ignores it."
        end
        dp "カメラとのBluetooth接続を解除します。"
        weakSelf.bluetoothConnector.peripheral = nil
      end

      dp "カメラの電源を切った後にWi-Fi接続が無効(もしくは他SSIDへ再接続)になるまで待ちます。"
      if lastConnectionType == OLYCameraConnectionTypeWiFi
        dp "MARK: カメラ本体のLEDはすぐに消灯するが、iOS側のWi-Fi接続が無効になるまで、10秒とか20秒とか、思っていたよりも時間がかかります。"
        dp "作者の環境ではiPhone 4Sだと10秒程度かかっています。"
        weakSelf.reportBlockConnectingWifi(progressView, true)
        Dispatch::Queue.main.async {
          weakSelf.showWifiSettingCell.detailTextLabel.text = "DisconnectingWifi"
        }
        if weakSelf.wifiConnector.waitForDisconnected(20.0)
          dp "エラーを無視して続行します。"
          dp "An error occurred, but ignores it."
        end
      end

      dp "画面表示を更新します。"
      Dispatch::Queue.main.async {
        weakSelf.updateShowBluetoothSettingCell
        weakSelf.updateShowWifiSettingCell
        weakSelf.updateCameraConnectionCells
        # weakSelf.updateCameraOperationCells
      }

      dp "カメラの接続解除が完了しました。"
      weakSelf.reportBlockFinishedToProgress(progressView)
    end
  end

  def openWifiConfig
    url = NSURL.URLWithString("prefs:root=WIFI")
    UIApplication.sharedApplication.openURL(url)
  end

  # 進捗画面に処理完了を報告します。
  def reportBlockFinishedToProgress(progress)
    Dispatch::Queue.main.sync {
      image = UIImage.imageNamed("Progress-Checkmark")
      progressImageView = UIImageView.alloc.initWithImage(image)
      progressImageView.tintColor = UIColor.whiteColor
      progress.customView = progressImageView
      progress.mode = MBProgressHUDModeCustomView
      sleep(1)
    }
  end

  # 進捗画面にWi-Fi接続中を報告します。
  # disconnect == true のときは切断中を表現
  def reportBlockConnectingWifi(progress, disconnect = false)
    Dispatch::Queue.main.sync {
      images = [
        UIImage.imageNamed("Progress-Wifi-25"),
        UIImage.imageNamed("Progress-Wifi-50"),
        UIImage.imageNamed("Progress-Wifi-75"),
        UIImage.imageNamed("Progress-Wifi-100")
      ]
      images.reverse! if disconnect
      progressImageView = UIImageViewAnimation.alloc.initWithImage(images[0])
      progressImageView.tintColor = UIColor.whiteColor
      progressImageView.setAnimationTemplateImages(images)
      progressImageView.animationDuration = 1.0
      progressImageView.alpha = 0.75

      progress.customView = progressImageView
      progress.mode = MBProgressHUDModeCustomView

      progressImageView.startAnimating
    }
  end

  # 進捗画面に電源投入中を報告します。
  # 【重要】サイズ的ユニバーサル画像リソースのためにgem 'ib'をつかっています
  # 使い方：http://blog.76things.com/asset-catalogs-with-rubymotion/
  def reportBlockWakingUp(progress)
    Dispatch::Queue.main.sync {
      images = [
        UIImage.imageNamed("Progress-Power-10"),
        UIImage.imageNamed("Progress-Power-20"),
        UIImage.imageNamed("Progress-Power-30"),
        UIImage.imageNamed("Progress-Power-40"),
        UIImage.imageNamed("Progress-Power-50"),
        UIImage.imageNamed("Progress-Power-60"),
        UIImage.imageNamed("Progress-Power-70"),
        UIImage.imageNamed("Progress-Power-80"),
        UIImage.imageNamed("Progress-Power-90"),
        UIImage.imageNamed("Progress-Power-100"),
        UIImage.imageNamed("Progress-Power-70"),
        UIImage.imageNamed("Progress-Power-40")
      ]
      progressImageView = UIImageViewAnimation.alloc.initWithImage(images[0])
      progressImageView.tintColor = UIColor.whiteColor
      progressImageView.setAnimationTemplateImages(images)
      progressImageView.animationDuration = 1.0
      progressImageView.alpha = 0.75

      progress.customView = progressImageView
      progress.mode = MBProgressHUDModeCustomView

      progressImageView.startAnimating
    }
  end

  def alertOnMainThreadWithMessage(message, title:title)
    Dispatch::Queue.main.async {
      App.alert(title, message: message)
    }
  end

end
