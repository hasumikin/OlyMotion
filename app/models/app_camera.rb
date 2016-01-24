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

  def cameraActionStatus
    # 撮影タイプ別に検査します。
    case self.cameraActionType
    when 'AppCameraActionTypeTakingPictureSingle'
      # 静止画を単写で撮影中
      return 'AppCameraActionStatusTakingPictureSingle' if self.takingPicture
    when 'AppCameraActionTypeTakingPictureSequential'
      # 静止画を連写で撮影中
      return 'AppCameraActionStatusTakingPictureSequential' if self.takingPicture
    when 'AppCameraActionTypeTakingPictureAutoBracketing'
      # 静止画をオートブラケットで撮影中
      return 'AppCameraActionStatusTakingPictureAutoBracketing' if self.runningTakingPluralPictures
    when 'AppCameraActionTypeTakingPictureIntervalTimer'
      # 静止画をインターバルタイマーで撮影中
      return 'AppCameraActionStatusTakingPictureIntervalTimer' if self.runningTakingPluralPictures
    when 'AppCameraActionTypeTakingPictureCombination'
      # 静止画をオートブラケット＋インターバルタイマーで撮影中
      return 'AppCameraActionStatusTakingPictureCombination' if self.runningTakingPluralPictures
    when 'AppCameraActionTypeRecordingVideo'
      # 動画を撮影中
      return 'AppCameraActionStatusRecordingVideo' if self.recordingVideo
    when OLYCameraActionTypeUnknown
    else
      # ありえません。
    end
    # 撮影していません。
    'AppCameraActionStatusReady'
  end

  def cameraActionType
    # 撮影モード/ドライブモードの種別を検査します。
    case actionType
    when OLYCameraActionTypeSingle
      # 静止画を単写で撮影。次の検査へ
    when OLYCameraActionTypeSequential
      # 静止画を連写で撮影
      return 'AppCameraActionTypeTakingPictureSequential'
    when OLYCameraActionTypeMovie
      # 動画を撮影
      return 'AppCameraActionTypeRecordingVideo'
    when OLYCameraActionTypeUnknown
    else
      # ありえません。
      return 'AppCameraActionTypeUnknown'
    end

    # # オートブラケット撮影が有効か検査します。
    autoBracketingModeEnabled = false
    # if self.autoBracketingMode != 'AppCameraAutoBracketingModeDisabled'
    #   error = Pointer.new(:object)
    #   takemode = cameraPropertyValue(CameraPropertyTakemode, error:error)
    #   if takemode.isEqualToString(CameraPropertyValueTakemodeP) ||
    #     takemode.isEqualToString(CameraPropertyValueTakemodeA) ||
    #     takemode.isEqualToString(CameraPropertyValueTakemodeS) ||
    #     takemode.isEqualToString(CameraPropertyValueTakemodeM]) {
    #     autoBracketingModeEnabled = true
    #   }
    # }

    # # インターバルタイマー撮影が有効か検査します。
    intervalTimerModeEnabled = false
    # if (self.intervalTimerMode != AppCameraIntervalTimerModeDisabled) {
    #   NSError *error = nil;
    #   NSString *takemode = [super cameraPropertyValue:CameraPropertyTakemode error:&error];
    #   if ([takemode isEqualToString:CameraPropertyValueTakemodeIAuto] ||
    #     [takemode isEqualToString:CameraPropertyValueTakemodeP] ||
    #     [takemode isEqualToString:CameraPropertyValueTakemodeA] ||
    #     [takemode isEqualToString:CameraPropertyValueTakemodeS] ||
    #     [takemode isEqualToString:CameraPropertyValueTakemodeM] ||
    #     [takemode isEqualToString:CameraPropertyValueTakemodeArt]) {
    #     intervalTimerModeEnabled = true
    #   }
    # }

    # 撮影モードを総合的に判断します。
    if autoBracketingModeEnabled && intervalTimerModeEnabled
      return 'AppCameraActionTypeTakingPictureCombination'
    elsif autoBracketingModeEnabled
      return 'AppCameraActionTypeTakingPictureAutoBracketing'
    elsif intervalTimerModeEnabled
      return 'AppCameraActionTypeTakingPictureIntervalTimer'
    end
    return 'AppCameraActionTypeTakingPictureSingle'
  end

  def camera(camera, notifyDidChangeCameraProperty:name, sender:sender)
    # for (id<OLYCameraPropertyDelegate> delegate in self.cameraPropertyDelegates) {
    @cameraPropertyDelegates.each do |delegate|
      next if delegate == sender
      if delegate.respondsToSelector('camera:didChangeCameraProperty:')
        delegate.camera(camera, didChangeCameraProperty:name)
      end
    end
  end

  #
  # 拡大ビュー
  #
  def startMagnifyingLiveView(scale, error:error)
    dp "scale=#{scale}"
    # ライブビュー拡大が成功したらその時の倍率と表示範囲を保持しておきます。
    return false unless super(scale, error:error)
    area = magnifyingLiveViewArea(error)
    return false if !area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]
    overallViewSize = area[OLYCameraMagnifyingOverallViewSizeKey]# CGSizeValue];
    displayAreaRect = area[OLYCameraMagnifyingDisplayAreaRectKey]# CGRectValue];
    # MARK: 設定する順序がシビア。今このアプリでは、magnifyingLiveViewScaleをKVOしているので、それを一番最後に変更します。
    @magnifyingOverallViewSize = overallViewSize
    @magnifyingDisplayAreaRect = displayAreaRect
    @magnifyingLiveViewScale = scale
    return true
  end

  def startMagnifyingLiveViewAtPoint(point, scale:scale, error:error)
    dp "scale=#{scale}"
    # ライブビュー拡大が成功したらその時の倍率と表示範囲を保持しておきます。
    return false unless super(point, scale:scale, error:error)
    area = magnifyingLiveViewArea(error)
    return false if !area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]
    overallViewSize = area[OLYCameraMagnifyingOverallViewSizeKey]# CGSizeValue];
    displayAreaRect = area[OLYCameraMagnifyingDisplayAreaRectKey]# CGRectValue];
    # MARK: 設定する順序がシビア。今このアプリでは、magnifyingLiveViewScaleをKVOしているので、それを一番最後に変更します。
    @magnifyingOverallViewSize = overallViewSize
    @magnifyingDisplayAreaRect = displayAreaRect
    @magnifyingLiveViewScale = scale
    return true
  end

  def changeMagnifyingLiveViewScale(scale, error:error)
    dp "scale=#{scale}"
    # ライブビュー拡大を開始していない場合は変更されたことにします。
    unless @magnifyingLiveView
      @magnifyingLiveViewScale = scale
      return true
    end
    # ライブビュー拡大の倍率変更が成功したらその時の倍率と表示範囲を保持しておきます。
    return false unless super(scale, error:error)
    area = magnifyingLiveViewArea(error)
    return false if !area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]
    overallViewSize = area[OLYCameraMagnifyingOverallViewSizeKey]# CGSizeValue];
    displayAreaRect = area[OLYCameraMagnifyingDisplayAreaRectKey]# CGRectValue];
    # MARK: 設定する順序がシビア。今このアプリでは、magnifyingLiveViewScaleをKVOしているので、それを一番最後に変更します。
    @magnifyingOverallViewSize = overallViewSize
    @magnifyingDisplayAreaRect = displayAreaRect
    @magnifyingLiveViewScale = scale
    return true
  end

  def changeMagnifyingLiveViewArea(direction, error:error)
    dp "direction=#{direction}"
    # ライブビュー拡大の表示範囲移動が成功したらその時の表示範囲を保持しておきます。
    return false unless super(direction, error:error)
    area = magnifyingLiveViewArea(error)
    return false if !area[OLYCameraMagnifyingOverallViewSizeKey] || !area[OLYCameraMagnifyingDisplayAreaRectKey]
    overallViewSize = area[OLYCameraMagnifyingOverallViewSizeKey]# CGSizeValue];
    displayAreaRect = area[OLYCameraMagnifyingDisplayAreaRectKey]# CGRectValue];
    # MARK: 設定する順序がシビア。今このアプリでは、magnifyingLiveViewScaleをKVOしているので、それを一番最後に変更します。
    @magnifyingOverallViewSize = overallViewSize
    @magnifyingDisplayAreaRect = displayAreaRect
    return true
  end

  def stopMagnifyingLiveView(error)
    # ライブビュー拡大を止めます。
    return false unless super(error)
    # ライブビュー拡大の表示範囲を初期化しておきます。
    @magnifyingOverallViewSize = CGSizeZero
    @magnifyingDisplayAreaRect = CGRectZero
    return true
  end

end

