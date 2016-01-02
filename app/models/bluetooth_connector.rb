class BluetoothConnector
  BluetoothConnectionChangedNotification = "BluetoothConnectionChangedNotification"
  BluetoothConnectorErrorDomain = "BluetoothConnectorErrorDomain"

  attr_accessor :localName, :running, :queue, :centralManager

  def initialize
    @services = nil
    @localName = nil
    @timeout = 5.0
    # _queue = dispatch_queue_create([dispatchQueueName UTF8String], NULL);
    # Obj-cの↑を↓のように書いてみた
    #@queue = Dispatch::Queue.concurrent("#{App::ENV['APP_IDENTIFIER']}.BluetoothConnector.queue")
    #managerOptions = { CBCentralManagerOptionShowPowerAlertKey => true }
    # @centralManager = CBCentralManager.alloc.initWithDelegate(self, queue:@queue, options:managerOptions)
    # しかしうまくいかず、
    # https://groups.google.com/forum/#!topic/rubymotion/ja1HGzqPbF8
    # をみて↓のようにしてみた
    @centralManager = CBCentralManager.alloc.initWithDelegate(self, queue:Dispatch::Queue.main.dispatch_object)
  end

  def dealloc
    @services = nil
    @localName = nil
    @peripheral = nil
    #@queue = nil
    @centralManager = nil
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
      # すでに実行中です。
      internalError = self.createError('BluetoothConnectorErrorBusy', description:"DiscorverPeripheralIsRunnning")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      return true
    end
    # MARK: セントラルマネージャを生成してすぐにステータスを参照するとまだ電源オンしていない場合があります。
    managerStartTime = Time.now
    while (@centralManager.state != CBCentralManagerStatePoweredOn && Time.now - managerStartTime < @timeout)
      sleep(0.05)
    end
    if @centralManager.state != CBCentralManagerStatePoweredOn
      # Bluetoothデバイスは利用できません。
      internalError = self.createError('BluetoothConnectorErrorNotAvailable', description:"CBCentralManagerStateNotPoweredOn")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      return false
    end
    if @peripheral && @peripheral.name == @localName
      # すでに検索してあるんじゃないですか。
      internalError = self.createError('BluetoothConnectorErrorConnected', description:"BluetoothPeripheralFound")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      # エラーは無視して続行します。
    end

    # ペリフェラルをスキャンします。
    @running = true
    @peripheral = nil
    @centralManager.stopScan
    scanOptions = {
      'CBCentralManagerScanOptionAllowDuplicatesKey' => false
    }
    @centralManager.scanForPeripheralsWithServices(self.services, options:scanOptions)
    scanStartTime = Time.now
    while (!@peripheral && Time.now - scanStartTime < @timeout)
      sleep(0.05)
    end
    @centralManager.stopScan
    discovered = (@peripheral != nil)
    @running = false

    # ペリフェラルが見つかっていたら通知します。
    if discovered
      notificationCenter = NSNotificationCenter.defaultCenter
      notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
    else
      userInfo = {
        'NSLocalizedDescriptionKey' => "DiscoveringBluetoothPeripheralTimedOut"
      }
      theError = NSError.errorWithDomain(BluetoothConnectorErrorDomain, code:'BluetoothConnectorErrorTimeout', userInfo:userInfo)
      puts "error=#{theError}"
      if error
        error = theError
      end
    end
    return discovered
  end

  def connectPeripheral(error)
    if @running
      # すでに実行中です。
      internalError = self.createError('BluetoothConnectorErrorBusy', description:"ConnectPeripheralIsRunnning")
      puts "error=#{internalError}"
      if error
        *error = internalError;
      end
      return false
    end
    # MARK: セントラルマネージャを生成してすぐにステータスを参照するとまだ電源オンしていない場合があります。
    managerStartTime = Time.now
    while (@centralManager.state != CBCentralManagerStatePoweredOn && Time.now - managerStartTime < @timeout)
      sleep(0.05)
    end
    if @centralManager.state != CBCentralManagerStatePoweredOn
      # Bluetoothデバイスは利用できません。
      internalError = self.createError('BluetoothConnectorErrorNotAvailable', description:"CBCentralManagerStateNotPoweredOn")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      return false
    end
    unless @peripheral
      # ペリフェラルが用意されていません。
      internalError = self.createError('BluetoothConnectorErrorNoPeripheral', description:"NoBluetoothPeripherals")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      return false
    end
    if @peripheral && @peripheral.name == @localName && @peripheral.state == CBPeripheralStateConnected
      # すでに接続してあるんじゃないですか。
      internalError = self.createError('BluetoothConnectorErrorConnected', description:"BluetoothPeripheralConnected")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      # エラーは無視して続行します。
    end

    # ペリフェラルに接続します。
    @running = true
    connectOptions = {
      'CBConnectPeripheralOptionNotifyOnConnectionKey' => false,
      'CBConnectPeripheralOptionNotifyOnDisconnectionKey' => false,
      'CBConnectPeripheralOptionNotifyOnNotificationKey' => false
    }
    @centralManager.connectPeripheral(@peripheral, options:connectOptions)
    scanStartTime = Time.now
    while (@peripheral.state != CBPeripheralStateConnected && Time.now - scanStartTime < @timeout)
      sleep(0.05)
    end
    connected = (@peripheral.state == CBPeripheralStateConnected)
    @running = false

    # ペリフェラルに接続していたら通知します。
    if connected
      notificationCenter = NSNotificationCenter.defaultCenter
      notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
    else
      userInfo = {
        'NSLocalizedDescriptionKey' => "ConnectingBluetoothPeripheralTimedOut"
      }
      theError = NSError.errorWithDomain(BluetoothConnectorErrorDomain, code:'BluetoothConnectorErrorTimeout', userInfo:userInfo)
      puts "error=#{theError}"
      if error
        error = theError
      end
    end
    return connected
  end

  def disconnectPeripheral(error)
    if @running
      # すでに実行中です。
      internalError = self.createError('BluetoothConnectorErrorBusy', description:"DisconnectPeripheralIsRunnning")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      return false
    end
    if @centralManager.state != CBCentralManagerStatePoweredOn
      # Bluetoothデバイスは利用できません。
      internalError = self.createError('BluetoothConnectorErrorNotAvailable', description:"CBCentralManagerStateNotPoweredOn")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      return false
    end
    unless @peripheral
      # ペリフェラルが用意されていません。
      internalError = self.createError('BluetoothConnectorErrorNoPeripheral', description:"NoBluetoothPeripherals")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      return false
    end
    if @peripheral && @peripheral.name == @localName && @peripheral.state == CBPeripheralStateDisconnected
      # すでに切断してあるんじゃないですか。
      internalError = self.createError('BluetoothConnectorErrorDisconnected', description:"BluetoothPeripheralDisconnected")
      puts "error=#{internalError}"
      if error
        error = internalError
      end
      # エラーは無視して続行します。
    end

    # ペリフェラルの接続を解除します。
    @running = true
    @centralManager.cancelPeripheralConnection(@peripheral)
    scanStartTime = Time.now
    while (@peripheral.state != CBPeripheralStateDisconnected && Time.now - scanStartTime < self.timeout)
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
        'NSLocalizedDescriptionKey' => "DisconnectingBluetoothPeripheralTimedOut"
      }
      theError = NSError.errorWithDomain(BluetoothConnectorErrorDomain, code:'BluetoothConnectorErrorTimeout', userInfo:userInfo)
      puts "error=#{theError}"
      if error
        error = theError
      end
    end
    return disconnected
  end

  # セントラルマネージャの状態が変わった時に呼び出されます。
  def centralManagerDidUpdateState(central)
    puts "central.state=#{central.state}"
    # CBCentralManagerStateUnknown = 0
    # CBCentralManagerStateResetting = 1
    # CBCentralManagerStateUnsupported = 2
    # CBCentralManagerStateUnauthorized = 3
    # CBCentralManagerStatePoweredOff = 4
    # CBCentralManagerStatePoweredOn = 5

    notificationCenter = NSNotificationCenter.defaultCenter
    notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
  end

  # セントラルマネージャがペリフェラルを見つけた時に呼び出されます。
  def centralManager(central, didDiscoverPeripheral:peripheral, advertisementData:advertisementData, rssi:rSSI) # rssiをとりあえず小文字にしてコンパイルを通す
    puts "peripheral=#{peripheral}, advertisementData=#{advertisementData}, RSSI=#{rssi}"

    if advertisementData[CBAdvertisementDataLocalNameKey] == @localName
      @centralManager.stopScan
      @peripheral = peripheral
    end
  end

  # ペリフェラルに接続した時に呼び出されます。
  def centralManager(central, didConnectPeripheral:peripheral)
    puts "peripheral=#{peripheral}"
  end

  # ペリフェラルに接続失敗した時に呼び出されます。
  def centralManager(central, didFailToConnectPeripheral:peripheral, error:error)
    puts "peripheral=#{peripheral}"
  end

  # ペリフェラルの接続が解除された時に呼び出されます。
  def centralManager(central, didDisconnectPeripheral:peripheral, error:error)
    puts "peripheral=#{peripheral}"

    # 切断処理中以外にBluetoothの切断通知を受けた場合は、ここからさらに通知します。
    unless @running
      notificationCenter = NSNotificationCenter.defaultCenter
      notificationCenter.postNotificationName(BluetoothConnectionChangedNotification, object:self)
    end
  end

  # エラー情報を作成します。
  def createError(code, description:description)
    puts "code=#{code}, description=#{description}"

    userInfo = {
      'NSLocalizedDescriptionKey' => description
    }
    error = NSError.alloc.initWithDomain(BluetoothConnectorErrorDomain, code:code, userInfo:userInfo)
    return error
  end

end
