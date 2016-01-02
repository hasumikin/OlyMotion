class SettingsViewController < UIViewController

  include UIViewControllerThreading

  WifiConnectionChangedNotification = "WifiConnectionChangedNotification"

  attr_accessor :bluetoothConnector, :wifiConnector

  def viewDidLoad
    super

    # ビューコントローラーの活動状態を初期化します。
    @startingActivity = false

    @setting = AppSetting.instance
    @camera = AppCamera.instance

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
            detail:
            '$ssid',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@showWifiSettingCell
          }
        ]
      },
      { title: 'Connection',
        rows: [
          { label:
            'Connect with Bluetooth',
            detail: '',
            accessory_type:
            UITableViewCellAccessoryNone,
            outlet: :@connectWithUsingBluetoothCell
          },
          { label:
            'Connect with Wi-Fi',
            detail: '',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@connectWithUsingWifiCell
          },
          { label:
            'Disconnect',
            detail: '',
            accessory_type:
            UITableViewCellAccessoryNone,
            outlet: :@disconnectCell
          },
          { label:
            'Disconnect and Sleep',
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

    notificationCenter = NSNotificationCenter.defaultCenter
    notificationCenter.addObserver(self, selector:'applicationDidBecomeActive:', name:'UIApplicationDidBecomeActiveNotification', object:nil)
    notificationCenter.addObserver(self, selector:'applicationWillResignActive:', name:'UIApplicationWillResignActiveNotification', object:nil)
    # notificationCenter.addObserver(self, selector:'applicationDidEnterBackground:', name:'UIApplicationDidEnterBackgroundNotification', object:nil)
    # notificationCenter.addObserver(self, selector:'applicationWillEnterForeground:', name:'UIApplicationWillEnterForegroundNotification', object:nil)

    # Wi-Fiの接続状態を監視するインスタンス
    @wifiConnector = WifiConnector.new
    notificationCenter.addObserver(self, selector:'didChangeWifiStatus:', name:WifiConnector::WifiStatusChangedNotification, object:nil)
    # Bluetoothの接続状態を監視するインスタンス
    @bluetoothConnector = BluetoothConnector.new
  end

  def viewDidAppear(animated)
    super(animated)

    unless @startingActivity
      # MARK: iOS9では初回の画面表示の際にapplicationDidBecomeActiveが呼び出されないのでここでフォローします。
      # todo: バージョン判定のRubymotion的書き方がわからないので常に実行。そのうち直す
      # if NSProcessInfo.processInfo.isOperatingSystemAtLeastVersion('9.0')
      # puts "The application is running on iOS9!"
      applicationDidBecomeActive(nil)
      # end
      @startingActivity = true
    end
  end

  # Wi-Fi接続の状態が変化した時に呼び出されます。
  def didChangeWifiStatus(notification)
    # メインスレッド以外から呼び出された場合は、メインスレッドに投げなおします。
    unless NSThread.isMainThread
      weakSelf = WeakRef.new(self)
      # weakSelf.executeAsynchronousBlockOnMainThread -> {
      Dispatch::Queue.main.async {
        puts "weakSelf=#{weakSelf}"
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


  # アプリケーションがアクティブになる時に呼び出されます。
  def applicationDidBecomeActive(notification)
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
    # Wi-Fiの接続監視を停止
    @wifiConnector.stopMonitoring
  end

  # ひとつひとつのセルのenableをスイッチ
  def updateCell(cell, enable, accessoryType = nil)
    if cell
      cell.userInteractionEnabled  = enable unless enable.nil?
      cell.textLabel.enabled       = enable unless enable.nil?
      cell.detailTextLabel.enabled = enable unless enable.nil?
      cell.accessoryType    = accessoryType if accessoryType
    end
  end

  # アプリ接続の状態を画面に表示します。
  def updateCameraConnectionCells
    if @camera.connected && @camera.connectionType == OLYCameraConnectionTypeBluetoothLE
      # Bluetoothで接続中です。
      updateCell(@connectWithUsingBluetoothCell, false, UITableViewCellAccessoryCheckmark)
      updateCell(@connectWithUsingWiFiCell, false, UITableViewCellAccessoryNone)
      updateCell(@disconnectCell, true)
      updateCell(@disconnectAndSleepCell, true)
    elsif @camera.connected && @camera.connectionType == OLYCameraConnectionTypeWiFi
      # Wi-Fiで接続中です。
      updateCell(@connectWithUsingBluetoothCell, false, UITableViewCellAccessoryNone)
      updateCell(@connectWithUsingWiFiCell, false, UITableViewCellAccessoryCheckmark)
      updateCell(@disconnectCell, true)
      updateCell(@disconnectAndSleepCell, true)
    else
      # 未接続です。
      if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
        # Bluetooth使用可
        updateCell(@connectWithUsingBluetoothCell, true)
      else
        # Bluetooth使用不可
        updateCell(@connectWithUsingBluetoothCell, false)
      end
      if @wifiConnector.connectionStatus == 'WifiConnectionStatusConnected'
        if @wifiConnector.cameraStatus == 'WifiCameraStatusReachable'
          # Wi-Fi接続済みで接続先はカメラ
          updateCell(@connectWithUsingWiFiCell, true)
        elsif @wifiConnector.cameraStatus == 'WifiCameraStatusUnreachable'
          # Wi-Fi接続済みで接続先はカメラではない
          if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
            # Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし
            # だが、カメラの電源を入れることぐらいはできるかもしれない
            updateCell(@connectWithUsingWiFiCell, true)
          else
            # Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし
            updateCell(@connectWithUsingWiFiCell, false)
          end
        else
          # Wi-Fi接続済みで接続先は確認中
          # カメラにアクセスできるか否かが確定するまでの間は操作を許可しない
          updateCell(@connectWithUsingWiFiCell, false)
        end
      else
        if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
          # Wi-Fi未接続でBluetooth経由の電源投入により自動接続できる見込みあり
          updateCell(@connectWithUsingWiFiCell, true)
        else
          # Wi-Fi未接続でBluetooth使用不可なため自動でカメラに接続できる見込みなし
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
      elsif cameraStatus == 'WifiCameraStatusUnreachable12'
        @wifiConnector.ssid ? "WifiNotConnected2(#{@wifiConnector.ssid})" : "WifiNotConnected2(null)"
      else
        "WifiStatusUnknown1" # Wi-Fi接続済みで接続先は確認中
      end
    elsif wifiStatus == 'WifiConnectionStatusNotConnected'
      "WifiNotConnected"
    else
      "WifiStatusUnknown2"
    end
    @showWifiSettingCell.userInteractionEnabled = false
  end

  def updateShowBluetoothSettingCell
    @showBluetoothSettingCell.detailTextLabel.text = @setting['bluetoothLocalName'] if @showBluetoothSettingCell
  end

  # def viewWillAppear(animated)
  #   super
  # end

  def dealloc
    notificationCenter = NSNotificationCenter.defaultCenter
    # notificationCenter.removeObserver(self, name: BluetoothConnectionChangedNotification, object:nil)

    notificationCenter.removeObserver(self, name:'UIApplicationDidBecomeActiveNotification', object:nil)
    notificationCenter.removeObserver(self, name:'UIApplicationWillResignActiveNotification', object:nil)
    # notificationCenter.removeObserver(self, name:'UIApplicationDidEnterBackgroundNotification', object:nil)
    # notificationCenter.removeObserver(self, name:'UIApplicationWillEnterForegroundNotification', object:nil)
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
    cell.textLabel.text       = row[:label]
    cell.detailTextLabel.text = row[:detail]
    cell.accessoryType        = row[:accessory_type]
    instance_variable_set(row[:outlet], cell) if row[:outlet]
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
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    case @table_data[indexPath.section][:rows][indexPath.row][:label]
    when 'Bluetooth'
      BluetoothViewController.new.tap do |controller|
        self.navigationController.pushViewController(controller, animated:true)
      end
    when 'Connect with Bluetooth'
      didSelectRowAtConnectWithUsingBluetoothCell
    when 'Connect with Wi-Fi'
      didSelectRowAtConnectWithUsingWifiCell
    end
  end

  # 'Connect with using Wi-Fi'のセルが選択されたときに呼び出されます。
  def didSelectRowAtConnectWithUsingWifiCell
    # カメラへの接続するのに電源投入も必要か否かを調べます。
    demandToWakeUpWithUsingBluetooth = false
    if @wifiConnector.connectionStatus == 'WifiConnectionStatusConnected'
      if @wifiConnector.cameraStatus == 'WifiCameraStatusReachable'
        # Wi-Fi接続済みで接続先はカメラ
      elsif @wifiConnector.cameraStatus == 'WifiCameraStatusUnreachable'
        # Wi-Fi接続済みで接続先はカメラではない
        if @bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
          # Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし
          # だが、カメラの電源を入れることぐらいはできるかもしれない
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
    weakSelf.showProgressWhileExecutingBlock(true) { |progressView|
      puts "weakSelf=#{weakSelf}"

      # カメラに電源投入を試みます。
      if demandToWakeUpWithUsingBluetooth
        # カメラを探します。
        error_ptr = Pointer.new(:object)
        if weakSelf.bluetoothConnector.connectionStatus == 'BluetoothConnectionStatusNotFound'
          if !weakSelf.bluetoothConnector.discoverPeripheral(error_ptr)
            # カメラが見つかりませんでした。
            error = error_ptr[0]
            # weakSelf.showAlertMessage(error.localizedDescription, title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")]
            return
          end
        end

        # カメラにBluetooth接続します。
        if weakSelf.bluetoothConnector.connectionStatus == 'BluetoothConnectionStatusNotConnected'
          if !weakSelf.bluetoothConnector.connectPeripheral(error_ptr)
            # カメラにBluetooth接続できませんでした。
            error = error_ptr[0]
            # [weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")]
            return
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
        if !wokenUp
          # カメラの電源を入れるのに失敗しました。
          error = error_ptr[0]
          if error.domain.isEqualToString(OLYCameraErrorDomain) && error.code == OLYCameraErrorOperationAborted
            # MARK: カメラをUSB給電中に電源入れるとその後にWi-Fi接続できるようになるのにもかかわらずエラーが返ってくるようです。
            #     Error {
            #         Domain = OLYCameraErrorDomain
            #         Code = 195887114 (OLYCameraErrorOperationAborted)
            #         UserInfo = { NSLocalizedDescription=The camera did not respond in time. }
            #     }
            # エラーにすると使い勝手が悪いので、無視して続行します。
            puts "An error occurred, but ignore it."
            wokenUp = true
          else
            # weakSelf.showAlertMessage(error.localizedDescription, title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")]
          end
        end
        @camera.bluetoothPeripheral = nil
        @camera.bluetoothPassword = nil

        # カメラとのBluetooth接続を解除します。
        # MARK: このタイミングで切断することによって、果たしてWi-FiとBluetoothの電波干渉を避けることができるか?
        if !weakSelf.bluetoothConnector.disconnectPeripheral(error_ptr)
          # カメラとのBluetooth接続解除に失敗しました。
          # エラーを無視して続行します。
          puts "An error occurred, but ignores it."
        end
        weakSelf.bluetoothConnector.peripheral = nil

        # カメラの電源を入れるのに失敗している場合はここで諦めます。
        return nil unless wokenUp

        # カメラの電源を入れた後にカメラにアクセスできるWi-Fi接続が有効になるまで待ちます。
        # MARK: カメラ本体のLEDはすぐに接続中(緑)になるが、iOS側のWi-Fi接続が有効になるまで、10秒とか20秒とか、思っていたよりも時間がかかります。
        # 作者の環境ではiPhone 4Sだと10秒程度かかっています。
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
            App.alert "CouldNotDiscoverWifiConnection"
          else
            # カメラにアクセスできるWi-Fi接続ではありませんでした。(すでに別のアクセスポイントに接続している)
            App.alert "WifiConnectionIsNotCamera"
          end
          return
        end

        # 電源投入が完了しました。
        progressView.mode = MBProgressHUDModeIndeterminate
        puts "To wake the camera up is success."
      end

    #   # カメラにアプリ接続します。
    #   error_ptr = Pointer.new(:object)
    #   unless @camera.connect(OLYCameraConnectionTypeWiFi, error:error_ptr)
    #     # カメラにアプリ接続できませんでした。
    #     error = error_ptr[0]
    #     # [weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")]
    #     return
    #   end

    #   # スマホの現在時刻をカメラに設定します。
    #   # MARK: 保守モードでは受け付けないのでこのタイミングしかありません。
    #   unless @camera.changeTime(Time.now, error:error_ptr)
    #     # 時刻が設定できませんでした。
    #     error = error_ptr[0]
    #     # [weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")]
    #     return
    #   end

    #   # MARK: 実行モードがスタンドアロンモードのまま放置するとカメラの自動スリープが働いてしまってスタンドアロンモード以外へ変更できなくなってしまうようです。
    #   # カメラの自動スリープを防止するため、あらかじめ実行モードをスタンドアロンモード以外に変更しておきます。(取り敢えず保守モードへ)
    #   unless @camera.changeRunMode(OLYCameraRunModeMaintenance, error:error_ptr)
    #     # 実行モードを変更できませんでした。
    #     error = error_ptr[0]
    #     # [weakSelf showAlertMessage:error.localizedDescription title:NSLocalizedString(@"$title:CouldNotConnectWifi", @"ConnectionViewController.didSelectRowAtConnectWithUsingWifiCell")]
    #     return
    #   end

    #   # 画面表示を更新します。
    #   Dispatch::Queue.main.async {
    #     weakSelf.updateShowWifiSettingCell
    #     weakSelf.updateShowBluetoothSettingCell
    #     weakSelf.updateCameraConnectionCells
    #     # weakSelf.updateCameraOperationCells
    #     # weakSelf.tableView.scrollToRowAtIndexPath(weakSelf.visibleWhenConnected, atScrollPosition:UITableViewScrollPositionMiddle, animated:true)
    #   }

    #   # アプリ接続が完了しました。
    #   weakSelf.reportBlockFinishedToProgress(progressView)
    #   puts ""
    }
  end

end
