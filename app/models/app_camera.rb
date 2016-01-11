class AppCamera < OLYCamera

  include DebugConcern

  attr_accessor :connectionDelegates, :cameraPropertyDelegates, :playbackDelegates, :liveViewDelegates, :recordingDelegates, :recordingSupportsDelegates, :takingPictureDelegates

  # Rubymotionではシングルトンモジュールが使えない
  def self.instance
    Dispatch.once { @@instance ||= alloc.init }
    @@instance
  end

  def init()
    if super
      @connectionDelegates        = []#WeakRef.new(Array.new)
      @cameraPropertyDelegates    = []#WeakRef.new(Array.new)
      @playbackDelegates          = []#WeakRef.new(Array.new)
      @liveViewDelegates          = []#WeakRef.new(Array.new)
      @recordingDelegates         = []#WeakRef.new(Array.new)
      @recordingSupportsDelegates = []#WeakRef.new(Array.new)
      @takingPictureDelegates     = []#WeakRef.new(Array.new)

      self.connectionDelegate = self
      self.cameraPropertyDelegate = self
      self.playbackDelegate = self
      self.liveViewDelegate = self
      self.recordingDelegate = self
      self.recordingSupportsDelegate = self
    end
    self
  end

  # delegate

  def addConnectionDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.connectionDelegates
      delegates.addObject(delegate)
      self.connectionDelegates = delegates
    }
  end

  def removeConnectionDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.connectionDelegates
      delegates.removeObject(delegate)
      self.connectionDelegates = delegates
    }
  end

  def addCameraPropertyDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.cameraPropertyDelegates
      delegates.addObject(delegate)
      self.cameraPropertyDelegates = delegates
    }
  end

  def removeCameraPropertyDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.cameraPropertyDelegates
      delegates.removeObject(delegate)
      self.cameraPropertyDelegates = delegates
    }
  end

  def addPlaybackDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.playbackDelegates
      delegates.addObject(delegate)
      self.playbackDelegates = delegates
    }
  end

  def removePlaybackDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.playbackDelegates
      delegates.removeObject(delegate)
      self.playbackDelegates = delegates
    }
  end

  def addLiveViewDelegate(delegate)
    dp "delegate=#{delegate.description}"
    # Dispatch.once {
      # delegates = @liveViewDelegates
      # delegates.addObject(delegate)
      # @liveViewDelegates = delegates
      @liveViewDelegates << delegate
    # }
  end

  def removeLiveViewDelegate(delegate)
    dp "delegate=#{delegate.description}"
    # Dispatch.once {
    #   delegates = self.liveViewDelegates
    #   delegates.removeObject(delegate)
    #   self.liveViewDelegates = delegates
@liveViewDelegates.delete(delegate)
    # }
  end

  def addRecordingDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.recordingDelegates
      delegates.addObject(delegate)
      self.recordingDelegates = delegates
    }
  end

  def removeRecordingDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.recordingDelegates
      delegates.removeObject(delegate)
      self.recordingDelegates = delegates
    }
  end

  def addRecordingSupportsDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.recordingSupportsDelegates
      delegates.addObject(delegate)
      self.recordingSupportsDelegates = delegates
    }
  end

  def removeRecordingSupportsDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.recordingSupportsDelegates
      delegates.removeObject(delegate)
      self.recordingSupportsDelegates = delegates
    }
  end

  def addTakingPictureDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.takingPictureDelegates
      delegates.addObject(delegate)
      self.takingPictureDelegates = delegates
    }
  end

  def removeTakingPictureDelegate(delegate)
    dp "delegate=#{delegate.description}"
    Dispatch.once {
      delegates = self.takingPictureDelegates
      delegates.removeObject(delegate)
      self.takingPictureDelegates = delegates
    }
  end

  def camera(camera, didUpdateLiveView:data, metadata:metadata)
    # # デリゲート集合を取得します。
    # # 別スレッドでイベントハンドラの追加削除を行っている可能性があるのでスナップショットを取り出します。
    # # FIXME: 処理効率が悪いですが他に良い方法が見つからず。
    # delegates = []
    # Dispatch.once {
    #   return if @liveViewDelegates.size == 0
    #   delegates = @liveViewDelegates.dup
    # }
    # ↑@synchronized (self) {} のRubyMotion的書き方がわからないので、とりあえず単純に書く
    #
    # デリゲート集合のそれぞれにイベントを伝達します。
    # delegates.each do |delegate|
    @liveViewDelegates.each do |delegate|
      if delegate.respondsToSelector('camera:didUpdateLiveView:metadata:')
        delegate.camera(camera, didUpdateLiveView:data, metadata:metadata)
      end
    end
  end

end
