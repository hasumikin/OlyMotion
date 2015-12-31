class SettingsViewController < UIViewController

  WifiConnectionChangedNotification = "WifiConnectionChangedNotification"

  def viewDidLoad
    super

    # ビューコントローラーの活動状態を初期化します。
    @startingActivity = false

    @setting = AppSetting.instance

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self

    @table_data = [
      { title: 'Access Method',
        rows: [
          { label: 'Bluetooth', detail: '$bluetoothLocalName', accessory_type: UITableViewCellAccessoryDisclosureIndicator },
          { label: 'Wi-Fi',     detail: '$ssid', accessory_type: UITableViewCellAccessoryNone }
        ]
      },
      { title: 'Connection',
        rows: [
          { label: 'Connect with Bluetooth', detail: '', accessory_type: UITableViewCellAccessoryNone },
          { label: 'Connect with Wi-Fi',     detail: '', accessory_type: UITableViewCellAccessoryNone }
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
    updateCameraConnectionCells
    # updateCameraOperationCells
  end

  # アプリケーションが非アクティブになる時に呼び出されます。
  def applicationWillResignActive(notification)
    # Wi-Fiの接続監視を停止
    @wifiConnector.stopMonitoring
  end

  # Wi-Fi接続の状態を表示します。
  def updateShowWifiSettingCell
    wifiStatus = @wifiConnector.connectionStatus
    @table_data[0][:rows][1][:detail] = if wifiStatus == 'WifiConnectionStatusConnected'
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
    @table.reloadData
  end

  def viewWillAppear(animated)
    super

    @table_data[0][:rows][0][:detail] = @setting['bluetoothLocalName']
    @table.reloadData
  end

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
    end
  end

end
