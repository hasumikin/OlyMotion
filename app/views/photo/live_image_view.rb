class LiveImageView < UIImageView
  include DebugConcern

  def initWithFrame(frame)
    dp "frame=#{NSStringFromCGRect(frame)}"
    super(frame)
    return nil unless self
    initComponent
    return self
  end

  def initWithCoder(decoder)
    dp "decoder=#{decoder}"
    super(decoder)
    return nil unless self
    initComponent
    return self
  end

  def initComponent
    @flashingOpacity = 1.0
    @flashingColor = UIColor.colorWithRed(1.0, green:1.0, blue:1.0, alpha:1.0)
    @focusFrameBorderWidth = 1.0
    @focusFrameBorderOpacity = 1.0
    @focusFrameBorderColorStatusRunning = UIColor.colorWithRed(0.75, green:1.0, blue:0.75, alpha:1.0)
    @focusFrameBorderColorStatusLocked = UIColor.colorWithRed(0.0, green:1.0, blue:0.0, alpha:1.0)
    @focusFrameBorderColorStatusFailed = UIColor.colorWithRed(1.0, green:0.0, blue:0.0, alpha:1.0)
    @exposureFrameBorderWidth = 1.0
    @exposureFrameBorderOpacity = 1.0
    @exposureFrameBorderColorStatusRunning = UIColor.colorWithRed(1.0, green:1.0, blue:0.75, alpha:1.0)
    @exposureFrameBorderColorStatusLocked = UIColor.colorWithRed(1.0, green:1.0, blue:0.0, alpha:1.0)
    @exposureFrameBorderColorStatusFailed = UIColor.colorWithRed(1.0, green:0.0, blue:0.0, alpha:1.0)
    @faceFrameBorderWidth = 1.0
    @faceFrameBorderOpacity = 1.0
    @faceFrameBorderColor = UIColor.colorWithRed(0.0, green:0.0, blue:1.0, alpha:1.0)
    @autoFocusEffectiveAreaBorderWidth = 2.0
    @autoFocusEffectiveAreaBorderOpacity = 0.5
    @autoFocusEffectiveAreaBorderColor = UIColor.colorWithRed(1.0, green:0.0, blue:0.0, alpha:1.0)
    @autoExposureEffectiveAreaBorderWidth = 2.0
    @autoExposureEffectiveAreaBorderOpacity = 0.5
    @autoExposureEffectiveAreaBorderColor = UIColor.colorWithRed(1.0, green:0.0, blue:0.0, alpha:1.0)
    @gridBands = 3
    @gridLineWidth = 1.0
    @gridLineOpacity = 1.0
    @gridLineColor = UIColor.colorWithRed(1.0, green:1.0, blue:1.0, alpha:1.0)

    CATransaction.begin
    CATransaction.setValue(KCFBooleanTrue, forKey:KCATransactionDisableActions)

    # 後から追加したレイヤーの方が手前に現れます。
    # フラッシュ表現のレイヤーを一番手前に表示したいので一番最後にビューに追加します。

    # # グリッドに関する情報を初期化します。
    # @showingGrid = false
    # @gridRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
    # gridLayer = LiveImageGridLayer.layer
    # gridLayer.gridBands = @gridBands
    # gridLayer.gridLineWidth = @gridLineWidth
    # gridLayer.gridLineColor = @gridLineColor
    # gridLayer.opacity = 0.0
    # gridLayer.frame = @gridRect
    # gridLayer.shadowColor = UIColor.blackColor.CGColor
    # gridLayer.shadowOpacity = @gridLineOpacity * 0.5
    # gridLayer.shadowRadius = @gridLineWidth + 1.0
    # gridLayer.shadowOffset = CGSizeZero
    # layer.addSublayer(gridLayer)
    # @gridLayer = gridLayer

    # AF有効枠に関する情報を初期化します。
    @showingAutoFocusEffectiveArea = false
    @autoFocusEffectiveAreaRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
    autoFocusEffectiveAreaLayer = CALayer.layer
    autoFocusEffectiveAreaLayer.borderWidth = @autoFocusEffectiveAreaBorderWidth
    autoFocusEffectiveAreaLayer.opacity = 0.0
    autoFocusEffectiveAreaLayer.frame = CGRectZero
    layer.addSublayer(autoFocusEffectiveAreaLayer)
    @autoFocusEffectiveAreaLayer = autoFocusEffectiveAreaLayer

    # AE有効枠に関する情報を初期化します。
    @showingAutoExposureEffectiveArea = false
    @autoExposureEffectiveAreaRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
    autoExposureEffectiveAreaLayer = CALayer.layer
    autoExposureEffectiveAreaLayer.borderWidth = @autoExposureEffectiveAreaBorderWidth
    autoExposureEffectiveAreaLayer.opacity = 0.0
    autoExposureEffectiveAreaLayer.frame = CGRectZero
    layer.addSublayer(autoExposureEffectiveAreaLayer)
    @autoExposureEffectiveAreaLayer = autoExposureEffectiveAreaLayer

    # 顔認識枠に関する情報を初期化します。
    faceFrames = 8 # 顔認識の最大検出数はどうやら8個らしいです。
    @showingFaceFrames = []
    @faceFrameRects = []
    @faceFrameLayers = []
    faceFrames.times do
      @showingFaceFrames << false
      faceFrameRect = CGRectMake(0.5, 0.5, 0.0, 0.0)
      @faceFrameRects << NSValue.valueWithCGRect(faceFrameRect)
      faceFrameLayer = CALayer.layer
      faceFrameLayer.borderWidth = @faceFrameBorderWidth
      faceFrameLayer.borderColor = @faceFrameBorderColor.CGColor
      faceFrameLayer.opacity = 0.0
      faceFrameLayer.frame = CGRectZero
      faceFrameLayer.shadowColor = UIColor.blackColor.CGColor
      faceFrameLayer.shadowOpacity = @faceFrameBorderOpacity * 0.5
      faceFrameLayer.shadowRadius = @faceFrameBorderWidth + 1.0
      faceFrameLayer.shadowOffset = CGSizeZero
      layer.addSublayer(faceFrameLayer)
      @faceFrameLayers << faceFrameLayer
    end

    # 自動露出枠に関する情報を初期化します。
    @showingExposureFrame = false
    @exposureFrameRect = CGRectMake(0.5, 0.5, 0.0, 0.0)
    exposureFrameLayer = CALayer.layer
    exposureFrameLayer.borderWidth = @exposureFrameBorderWidth
    exposureFrameLayer.opacity = 0.0
    exposureFrameLayer.frame = CGRectZero
    exposureFrameLayer.shadowColor = UIColor.blackColor.CGColor
    exposureFrameLayer.shadowOpacity = @exposureFrameBorderOpacity * 0.5
    exposureFrameLayer.shadowRadius = @exposureFrameBorderWidth + 1.0
    exposureFrameLayer.shadowOffset = CGSizeZero
    layer.addSublayer(exposureFrameLayer)
    @exposureFrameLayer = exposureFrameLayer

    # オートフォーカス枠に関する情報を初期化します。
    @showingFocusFrame = false
    @focusFrameRect = CGRectMake(0.5, 0.5, 0.0, 0.0)
    focusFrameLayer = CALayer.layer
    focusFrameLayer.borderWidth = @focusFrameBorderWidth
    focusFrameLayer.opacity = 0.0
    focusFrameLayer.frame = CGRectZero
    focusFrameLayer.shadowColor = UIColor.blackColor.CGColor
    focusFrameLayer.shadowOpacity = @focusFrameBorderOpacity * 0.5
    focusFrameLayer.shadowRadius = @focusFrameBorderWidth + 1.0
    focusFrameLayer.shadowOffset = CGSizeZero
    layer.addSublayer(focusFrameLayer)
    @focusFrameLayer = focusFrameLayer

    # フラッシュ表現に関する情報を初期化します。
    @showingFlashing = false
    flashingLayer = CALayer.layer
    flashingLayer.backgroundColor = @flashingColor.CGColor
    flashingLayer.opacity = 0.0
    flashingLayer.frame = self.bounds
    layer.addSublayer(flashingLayer)
    @flashingLayer = flashingLayer

    CATransaction.commit
  end

end
