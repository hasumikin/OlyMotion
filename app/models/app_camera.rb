class AppCamera < OLYCamera
  # attr_reader :connected, :connectionTypesMask

  # # Rubymotionではシングルトンモジュールが使えない
  # def self.instance
  #   Dispatch.once { @@instance ||= new }
  #   @@instance
  # end

  def initialize
    super
    # @connected = false
    # @connectionType = nil
    # delegate = UIApplication.sharedApplication.delegate
    # return nil unless delegate
    # delegate.camera
    # super
    # self.connectionDelegate = self
    # self.cameraPropertyDelegate = self
    # self.playbackDelegate = self
    # self.liveViewDelegate = self
    # self.recordingDelegate = self
    # self.recordingSupportsDelegate = self
    # self
  end

end
