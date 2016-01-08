class WifiConnector

  include DebugConcern

  WifiStatusChangedNotification = 'WifiStatusChangedNotification'

  attr_accessor :ssid, :bssid, :monitoring, :reachability, :networkStatus, :cameraResponded

  def initialize
    @ssid = nil
    @bssid = nil
    @reachability = Reachability.reachabilityForLocalWiFi
    @networkStatus = NotReachable
    @cameraResponded = false

    notificationCenter = NSNotificationCenter.defaultCenter
    notificationCenter.addObserver(self, selector:'reachabilityChanged:', name:'kReachabilityChangedNotification', object:nil)

    self
  end

  def dealloc
    notificationCenter = NSNotificationCenter.defaultCenter
    notificationCenter.removeObserver(self, name:'kReachabilityChangedNotification', object:nil)

    @reachabilityQueue = nil
    @reachability = nil
    @ssid = nil
    @bssid = nil
  end

  def connectionStatus
    case @networkStatus
    when ReachableViaWiFi
      'WifiConnectionStatusConnected'
    when NotReachable
      'WifiConnectionStatusNotConnected'
    else
      'WifiConnectionStatusUnknown'
    end
  end

  def cameraStatus
    case @networkStatus
    when ReachableViaWiFi
      @cameraResponded ? 'WifiCameraStatusReachable' : 'WifiCameraStatusUnreachable1'
    else
      'WifiCameraStatusUnreachable2'
    end
  end

  def startMonitoring
    if @monitoring
      # 監視はすでに実行中です。
      dp "MonitoringIsRunnning" + "WifiConnector.startMonitoring"
      return
    end

    weakSelf = WeakRef.new(self)
    Dispatch::Queue.concurrent.async {
      weakSelf.updateStatusWithToPingCamera(true)
      # 監視を開始します。
      # MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
      Dispatch::Queue.main.async {
        unless weakSelf.reachability.startNotifier
          # Reachabilityの通知開始に失敗しました。
          dp "CouldNotStartMonitoring" + "WifiConnector.startMonitoring"
          return
        end
      }
    }
    @monitoring = true
  end

  def stopMonitoring
    unless @monitoring
      # 監視は未実行です。
      dp "MonitoringIsNotRunnning" + "WifiConnector.stopMonitoring"
      return
    end

    weakSelf = WeakRef.new(self)
    Dispatch::Queue.concurrent.async {
      # 監視を停止します。
      # MARK: メインスレッドで呼び出さないとコールバックが呼び出されないようです。
      Dispatch::Queue.main.async {
        weakSelf.reachability.stopNotifier
      }
    }
    @monitoring = false
  end

  def waitForConnected(timeout)
    dp "timeout=#{timeout}"

    # 監視を一時的に停止します。
    if @monitoring
      weakSelf = WeakRef.new(self)
      Dispatch::Queue.concurrent.async {
        Dispatch::Queue.main.async {
          weakSelf.reachability.stopNotifier
        }
      }
    end

    # 接続状態の変化をポーリングします。
    connected = false
    waitStartTime = Time.now
    while (Time.now - waitStartTime < timeout)
      updateStatusWithToPingCamera(true)
      if @networkStatus == ReachableViaWiFi && @cameraResponded
        connected = true
        break
      end
      sleep(0.05)
    end

    # 監視を再開します。
    if @monitoring
      weakSelf = WeakRef.new(self)
      Dispatch::Queue.concurrent.async {
        Dispatch::Queue.main.async {
          weakSelf.reachability.startNotifier
        }
      }
    end

    connected
  end

  def waitForDisconnected(timeout)
    dp "timeout=#{timeout}"

    # 監視を一時的に停止します。
    if @monitoring
      weakSelf = WeakRef.new(self)
      Dispatch::Queue.concurrent.async {
        Dispatch::Queue.main.async {
          weakSelf.reachability.stopNotifier
        }
      }
    end

    # 接続状態の変化をポーリングします。
    disconnected = false
    waitStartTime = Time.now
    while (Time.now - waitStartTime < timeout)
      # MARK: カメラの電源オフ中にCGIコマンドを送信するとカメラが電源オフにならないようです。
      # ここでは、カメラへCGIコマンドを送らないように電源オフ(Wi-Fi切断)を待つようにしています。
      self.updateStatusWithToPingCamera(false)
      if @networkStatus == NotReachable || !@cameraResponded
        disconnected = true
        break
      end
      sleep(0.05)
    end

    # 監視を再開します。
    if @monitoring
      weakSelf = WeakRef.new(self)
      Dispatch::Queue.concurrent.async {
        Dispatch::Queue.main.async {
          weakSelf.reachability.startNotifier
        }
      }
    end

    disconnected
  end

  # Wi-Fi接続の状態が変化した時に呼び出されます。
  def reachabilityChanged(notification)
    weakSelf = WeakRef.new(self)
    Dispatch::Queue.concurrent.async {
      weakSelf.updateStatusWithToPingCamera(true)
    }
  end

  # 接続状態を更新します。
  def updateStatusWithToPingCamera(ping)
    previousNetworkStatus = @networkStatus
    previousCameraResponded = @cameraResponded

    @networkStatus = @reachability.currentReachabilityStatus
    if @networkStatus == NotReachable
      # Wi-Fi未接続
      @cameraResponded = false
      retreiveSSID
    elsif @networkStatus == ReachableViaWiFi
      # Wi-Fi接続済
      @cameraResponded = false
      retreiveSSID
      @cameraResponded = pingCamera if ping
    else
      # ここにはこないはず...
    end

    # 状態に変化があった時にだけ通知します。
    if @networkStatus != previousNetworkStatus || @cameraResponded != previousCameraResponded
      Dispatch::Queue.main.async {
        NSNotificationCenter.defaultCenter.postNotificationName(WifiStatusChangedNotification, object:self)
      }
    end
  end

  # ネットワーク接続情報を更新します。
  def retreiveSSID
    # SSIDとBSSIDを取得します。
    # MARK: iOSシミュレータでは正しく動作しません。SSIDもBSSIDもnilに設定されます。
    if @networkStatus == ReachableViaWiFi
      interfaces = CNCopySupportedInterfaces()
      if interfaces
        dict = CNCopyCurrentNetworkInfo(interfaces[0])
        if dict
          # https://gist.github.com/Baael/9604939 の書き方ではうまく行かなかった
          @ssid  = dict['SSID']
          @bssid = dict['BSSID']
        end
      end
    end
  end

  # カメラにアクセスできるか否かを確かめます。
  def pingCamera
    # 通信仕様書に従って、
    # 単発かつその後の動作に影響の少ないと思われるCGIコマンドをカメラへ送信してそのレスポンスを確認します。
    # 通信仕様書に沿った期待したレスポンスが返って来れば、このWi-Fiはカメラに接続していると判定します。
    cameraIPAddress = "192.168.0.10" # カメラのIPアドレス
    timeout = 3.0; # このタイムアウト秒数は暫定の値です。(値が短すぎると誤判断する)

    dp "カメラのIPアドレスへのルーティングがあるかを確認します。"
    reachability = Reachability.reachabilityWithHostName(cameraIPAddress)
    waitStartTime = Time.now
    while (reachability.currentReachabilityStatus == NotReachable && Time.now - waitStartTime < timeout)
      sleep(0.05)
    end
    if reachability.currentReachabilityStatus != ReachableViaWiFi
      dp "timed out"
      return false
    end

    client = AFMotion::Client.build("http://#{cameraIPAddress}/") do
      header "Accept",     "text/xml"
      header "User-Agent", "OlympusCameraKit"
      response_serializer :xml
    end
    # ↓同期実行する1/2
    client.completionQueue = Dispatch::Queue.concurrent.dispatch_object
    # ↓同期実行する2/2
    sema = Dispatch::Semaphore.new(0)
    connected = false
    client.get("get_connectmode.cgi") do |result|
      if result.success? && result.body.match('<connectmode>OPC</connectmode>')
        connected = true
      elsif result.operation.response.statusCode.to_s =~ /40\d/
        connected = false
      elsif result.failure?
        connected = false
      end
      sema.signal
    end
    sema.wait
    return connected
  end

end
