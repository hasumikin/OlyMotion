class AppCameraLog

  # Rubymotionではシングルトンモジュールが使えない
  def self.instance
    Dispatch.once { @@instance ||= new }
    @@instance
  end

  def initialize
    @mutableMessages = []
    OLYCameraLog.setDelegate(self)
  end

  def messages
    @mutableMessages.dup
  end

  def clearMessages
    @mutableMessages = []
    true
  end

  # カメラキットがログに出力しようとしたときに呼び出されます。
  def log(log, shouldOutputMessage:message, level:level)
    # ログファイル用のメッセージを作成します。
    currentTime = Time.now
    formatter = NSDateFormatter.alloc.init
    formatter.setTimeZone(NSTimeZone.localTimeZone)
    formatter.setDateFormat("HH:mm:ss.SSS")
    loggingTimestamp = formatter.stringFromDate(currentTime)
    loggingMessage = "#{loggingTimestamp} #{message}"
    # ログ履歴に記録します。
    @mutableMessages << loggingMessage
  end

end
