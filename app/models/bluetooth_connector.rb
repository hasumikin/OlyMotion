class BluetoothConnector

  include DebugConcern

  BluetoothConnectionChangedNotification = "BluetoothConnectionChangedNotification"
  BluetoothConnectorErrorDomain = "BluetoothConnectorErrorDomain"

  # エラーコード
  BluetoothConnectorErrorUnknown      = 1000 # 不明
  BluetoothConnectorErrorBusy         = 1001 # 処理中につき多忙
  BluetoothConnectorErrorNotAvailable = 1002 # 利用できない
  BluetoothConnectorErrorNoPeripheral = 1003 # ペリフェラルがない
  BluetoothConnectorErrorDisconnected = 1004 # すでに接続が解除されている
  BluetoothConnectorErrorConnected    = 1005 # すでに接続している
  BluetoothConnectorErrorTimeout      = 1006 # 処理待ちがタイムアウトした

  attr_accessor :localName, :running, :queue, :centralManager, :services, :peripheral

  def initialize
    @services = OLYCamera.bluetoothServices
    @localName = nil
    @timeout = 5.0
    @peripheral = nil
    # _queue = dispatch_queue_create([dispatchQueueName UTF8String], NULL);
    # Obj-cの↑を↓のように書いてみた
    #@queue = Dispatch::Queue.concurrent("#{App::ENV['APP_IDENTIFIER']}.BluetoothConnector.queue")
    #managerOptions = { CBCentralManagerOptionShowPowerAlertKey => true }
    # @centralManager = CBCentralManager.alloc.initWithDelegate(self, queue:@queue, options:managerOptions)
    # しかしうまくいかず、
    # https://groups.google.com/forum/#!topic/rubymotion/ja1HGzqPbF8
    # をみて↓のようにしてみた
    queue = Dispatch::Queue.concurrent("#{App::ENV['APP_IDENTIFIER']}.BluetoothConnector.queue").dispatch_object
    @centralManager = CBCentralManager.alloc.initWithDelegate(self, queue:queue)
  end

  def connectionStatus
    #if !(TARGET_IPHONE_SIMULATOR)
      if @centralManager.state == CBCentralManagerStatePoweredOn
        if @peripheral
          if @peripheral.state == CBPeripheralStateConnected
            return 'BluetoothConnectionStatusConnected'
          else
            return 'BluetoothConnectionStatusNotConnected'
          end
        else
          return 'BluetoothConnectionStatusNotFound'
        end
      end
    #endif
    return 'BluetoothConnectionStatusUnknown'
  end

  def discoverPeripheral(error)
    if @running
      dp "すでに実行中です。"
      internalError = createError(BluetoothConnectorErrorBusy, description:"DiscorverPeripheralIsRunnning")
      dp "error=#{internalError}"
      error[0] = internalError if error
      return true
    end

    # MARK: セントラルマネージャを生成してすぐにステータスを参照するとまだ電源オンしていない場合があります。
    managerStartTime = Time.now
    while (@centralManager.state != CBCentralManagerStatePoweredOn && Time.now - managerStartTime < @timeout)
      sleep(0.05)
    end
    if @centralManager.state != CBCentralManagerStatePoweredOn
      dp "Bluetoothデバイスは利用できません。"
      internalError = createError(BluetoothConnectorErrorNotAvailable, description:"CBCentralManagerStateNotPoweredOn")
      dp "error=#{internalError}"
      error[0] = internalError if error
      return false
    end

    if @peripheral && @peripheral.name == @localName
      dp "すでに検索してあるんじゃないですか。"
      internalError = createError(BluetoothConnectorErrorConnected, description:"BluetoothPeripheralFound")
      dp "error=#{internalError}"
      error[0] = internalError if error
      dp "エラーは無視して続行します。"
    end

    dp "ペリフェラルをスキャンします。"
    @running = true
    @peripheral = nil
    @centralManager.stopScan
    scanOptions = { CBCentralManagerScanOptionAllowDuplicatesKey => false }
    @centralManager.scanForPeripheralsWithServices(@services, options:scanOptions)
    scanStartTime = Time.now
    while (!@peripheral && Time.now - scanStartTime < @timeout)
      sleep(0.05)
    end
    @centralManager.stopScan
    discovered = (@peripheral != nil)
    @running = false

    dp "ペリフェラルが見つかっていたら通知します。"
    if discovered
      notificationCenter = NSNotificationCenter.defaultCenter
      notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
    else
      theError = createError(BluetoothConnectorErrorTimeout, description:'DiscoveringBluetoothPeripheralTimedOut')
      dp "error=#{theError}"
      error[0] = theError if error
    end
    return discovered
  end

  def connectPeripheral(error)
    if @running
      dp "すでに実行中です。"
      internalError = createError(BluetoothConnectorErrorBusy, description:"ConnectPeripheralIsRunnning")
      dp "error=#{internalError}"
      error[0] = internalError if error
      false
    end

    # MARK: セントラルマネージャを生成してすぐにステータスを参照するとまだ電源オンしていない場合があります。
    managerStartTime = Time.now
    while (@centralManager.state != CBCentralManagerStatePoweredOn && Time.now - managerStartTime < @timeout)
      sleep(0.05)
    end
    if @centralManager.state != CBCentralManagerStatePoweredOn
      dp "Bluetoothデバイスは利用できません。"
      internalError = createError(BluetoothConnectorErrorNotAvailable, description:"CBCentralManagerStateNotPoweredOn")
      dp "error=#{internalError}"
      error[0] = internalError if error
      false
    end

    unless @peripheral
      dp "ペリフェラルが用意されていません。"
      internalError = createError(BluetoothConnectorErrorNoPeripheral, description:"NoBluetoothPeripherals")
      dp "error=#{internalError}"
      error[0] = internalError if error
      false
    end

    if @peripheral && @peripheral.name == @localName && @peripheral.state == CBPeripheralStateConnected
      dp "すでに接続してあるんじゃないですか。"
      internalError = createError(BluetoothConnectorErrorConnected, description:"BluetoothPeripheralConnected")
      dp "error=#{internalError}"
      error[0] = internalError if error
      dp "エラーは無視して続行します。"
    end

    dp "ペリフェラルに接続します。"
    @running = true
    connectOptions = {
      CBConnectPeripheralOptionNotifyOnConnectionKey    => false,
      CBConnectPeripheralOptionNotifyOnDisconnectionKey => false,
      CBConnectPeripheralOptionNotifyOnNotificationKey  => false
    }
    @centralManager.connectPeripheral(@peripheral, options:connectOptions)
    scanStartTime = Time.now
    while (@peripheral.state != CBPeripheralStateConnected && Time.now - scanStartTime < @timeout)
      sleep(0.05)
    end
    connected = (@peripheral.state == CBPeripheralStateConnected)
    @running = false

    if connected
      dp "ペリフェラルに接続しているので通知します。"
      notificationCenter = NSNotificationCenter.defaultCenter
      notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
    else
      dp "ペリフェラルに接続していません。"
      userInfo = { NSLocalizedDescriptionKey => "ConnectingBluetoothPeripheralTimedOut" }
      theError = NSError.errorWithDomain(BluetoothConnectorErrorDomain, code:BluetoothConnectorErrorTimeout, userInfo:userInfo)
      dp "error=#{theError}"
      error[0] = theError if error
    end
    connected
  end

  def disconnectPeripheral(error)
    if @running
      # すでに実行中です。
      internalError = createError('BluetoothConnectorErrorBusy', description:"DisconnectPeripheralIsRunnning")
      dp "error=#{internalError}"
      error[0] = internalError if error
      return false
    end

    if @centralManager.state != CBCentralManagerStatePoweredOn
      # Bluetoothデバイスは利用できません。
      internalError = createError(BluetoothConnectorErrorNotAvailable, description:"CBCentralManagerStateNotPoweredOn")
      dp "error=#{internalError}"
      error[0] = internalError if error
      return false
    end

    unless @peripheral
      # ペリフェラルが用意されていません。
      internalError = createError(BluetoothConnectorErrorNoPeripheral, description:"NoBluetoothPeripherals")
      dp "error=#{internalError}"
      error[0] = internalError if error
      return false
    end

    if @peripheral && @peripheral.name == @localName && @peripheral.state == CBPeripheralStateDisconnected
      # すでに切断してあるんじゃないですか。
      internalError = createError(BluetoothConnectorErrorDisconnected, description:"BluetoothPeripheralDisconnected")
      dp "error=#{internalError}"
      error[0] = internalError if error
      # エラーは無視して続行します。
    end

    # ペリフェラルの接続を解除します。
    @running = true
    @centralManager.cancelPeripheralConnection(@peripheral)
    scanStartTime = Time.now
    while (@peripheral.state != CBPeripheralStateDisconnected && Time.now - scanStartTime < @timeout)
      sleep(0.05)
    end
    disconnected = (@peripheral.state == CBPeripheralStateDisconnected)
    @running = false

    # ペリフェラルの接続を解除できていたら通知します。
    if disconnected
      notificationCenter = NSNotificationCenter.defaultCenter
      notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
    else
      userInfo = {
        NSLocalizedDescriptionKey => "DisconnectingBluetoothPeripheralTimedOut"
      }
      theError = NSError.errorWithDomain(BluetoothConnectorErrorDomain, code:BluetoothConnectorErrorTimeout, userInfo:userInfo)
      dp "error=#{theError}"
      error[0] = theError if error
    end
    disconnected
  end

  # セントラルマネージャの状態が変わった時に呼び出されます。
  def centralManagerDidUpdateState(central)
    state = case central.state
    when 0
      'CBCentralManagerStateUnknown'
    when 1
      'CBCentralManagerStateResetting'
    when 2
      'CBCentralManagerStateUnsupported'
    when 3
      'CBCentralManagerStateUnauthorized'
    when 4
      'CBCentralManagerStatePoweredOff'
    when 5
      'CBCentralManagerStatePoweredOn'
    end
    dp "central.state=#{state}"

    notificationCenter = NSNotificationCenter.defaultCenter
    notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
  end

  # セントラルマネージャがペリフェラルを見つけた時に呼び出されます。
  def centralManager(central, didDiscoverPeripheral:peripheral, advertisementData:advertisementData, RSSI:rssi) # `RSSI:RSSI` -> `RSSI:rssi`にしたらコンパイルが通った
    dp "ペリフェラルを見つけました　peripheral=#{peripheral}, advertisementData=#{advertisementData}, RSSI=#{rssi}"
    dp "advertisementData[CBAdvertisementDataLocalNameKey]=#{advertisementData[CBAdvertisementDataLocalNameKey]}"
    if advertisementData[CBAdvertisementDataLocalNameKey] == @localName
      @peripheral = peripheral
      @centralManager.stopScan
      dp "peripheral.name=#{peripheral.name}"
      dp "peripheral.class=#{peripheral.class}"
      # camera = OLYCamera.new
      # camera.bluetoothPeripheral = peripheral
      # e = Pointer.new(:object)
      # camera.wakeup(e)
    end
  end

  # ペリフェラルに接続した時に呼び出されます。
  def centralManager(central, didConnectPeripheral:peripheral)
    dp "接続しました　peripheral=#{peripheral}"
  end

  # ペリフェラルに接続失敗した時に呼び出されます。
  def centralManager(central, didFailToConnectPeripheral:peripheral, error:error)
    dp "接続失敗しました　peripheral=#{peripheral}"
  end

  # ペリフェラルの接続が解除された時に呼び出されます。
  def centralManager(central, didDisconnectPeripheral:peripheral, error:error)
    dp "接続解除しました　peripheral=#{peripheral}"

    # 切断処理中以外にBluetoothの切断通知を受けた場合は、ここからさらに通知します。
    unless @running
      notificationCenter = NSNotificationCenter.defaultCenter
      notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
    end
  end

  # エラー情報を作成します。
  def createError(code, description:description)
    dp "code=#{code}, description=#{description}"
    userInfo = { NSLocalizedDescriptionKey => description }
    NSError.alloc.initWithDomain(BluetoothConnectorErrorDomain, code:code, userInfo:userInfo)
  end

end
