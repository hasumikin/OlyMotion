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

  def containsPoint(point)
    dp "touched point=#{point.x}, #{point.y}"
    CGRectContainsPoint(CGRectMake(0, 0, 1, 1), point)
    # CGRectContainsPoint(CGRectMake(0, 0, 414*1.5, 414), point)
    # CGRectContainsPoint(CGRectMake(0, 0, 414*1.5/2, 414/2), point)
  end

  def hideAutoFocusEffectiveArea(animated)
    # [self.autoFocusEffectiveAreaHideTimer invalidate]
    @autoFocusEffectiveAreaHideTimer = nil

    unless animated
      CATransaction.begin
      CATransaction.setValue(KCFBooleanTrue, forKey:KCATransactionDisableActions)
    end
    @autoFocusEffectiveAreaLayer.opacity = 0.0
    CATransaction.commit unless animated

    @showingAutoFocusEffectiveArea = false
  end

  def showAutoFocusEffectiveArea(rect, duration:duration, animated:animated)
    dp "showAutoFocusEffectiveArea:rect=#{NSStringFromCGRect(rect)}, duration=#{duration}"

    # @autoFocusEffectiveAreaHideTimer.invalidate
    @autoFocusEffectiveAreaHideTimer = nil

    return unless self.image

    rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image)
    # @FIXME
    scale = self.frame.size.width / self.image.size.width
    rectOnFrame = CGRectMake(rectOnImage.origin.x * scale, rectOnImage.origin.y * scale, rectOnImage.size.width * scale, rectOnImage.size.height * scale)
    rectOnImageView = self.convertRectFromImageArea(rectOnFrame)
    unless animated
      CATransaction.begin
      CATransaction.setValue(KCFBooleanTrue, forKey:KCATransactionDisableActions)
    end
    @autoFocusEffectiveAreaRect = rect
    @autoFocusEffectiveAreaLayer.borderColor = @autoFocusEffectiveAreaBorderColor.CGColor
    @autoFocusEffectiveAreaLayer.frame = rectOnImageView
    @autoFocusEffectiveAreaLayer.opacity = @autoFocusEffectiveAreaBorderOpacity
    CATransaction.commit unless animated

    @showingAutoFocusEffectiveArea = true

    if duration > 0
      @autoFocusEffectiveAreaHideTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target:self, selector:'didFireAutoFocusEffectiveAreaHideTimer:', userInfo:nil, repeats:false)
    end
  end

  def didFireFocusFrameHideTimer(timer)
    self.hideFocusFrame(true)
  end

  def didFireExposureFrameHideTimer(timer)
    self.hideExposureFrame(true)
  end

  def didFireAutoFocusEffectiveAreaHideTimer(timer)
    self.hideAutoFocusEffectiveArea(true)
  end

  def didFireAutoExposureEffectiveAreaHideTimer(timer)
    self.hideAutoExposureEffectiveArea(true)
  end

  def convertRectFromImageArea(rect)
    dp "convertRectFromImageArea:rect=#{NSStringFromCGRect(rect)}"

    return CGRectZero unless self.image

    imageTopLeft = rect.origin
    imageBottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))

    viewTopLeft = self.convertPointFromImageArea(imageTopLeft)
    viewBottomRight = self.convertPointFromImageArea(imageBottomRight)

    viewWidth = (viewBottomRight.x - viewTopLeft.x).abs
    viewHeight = (viewBottomRight.y - viewTopLeft.y).abs
    viewRect = CGRectMake(viewTopLeft.x, viewTopLeft.y, viewWidth, viewHeight)

    viewRect
  end

  def convertPointFromImageArea(point)
    dp "convertPointFromImageArea:point=#{NSStringFromCGPoint(point)}"

    return CGPointZero unless self.image

    viewPoint = point
    imageSize = self.image.size
    viewSize  = self.bounds.size
    ratioX = viewSize.width / imageSize.width
    ratioY = viewSize.height / imageSize.height
    scale = 0.0

    case self.contentMode
    when UIViewContentModeScaleToFill  # go to next label.
    when UIViewContentModeRedraw
      viewPoint.x *= ratioX
      viewPoint.y *= ratioY
    when UIViewContentModeScaleAspectFit
      scale = MIN(ratioX, ratioY)
      viewPoint.x *= scale
      viewPoint.y *= scale
      viewPoint.x += (viewSize.width  - imageSize.width  * scale) / 2.0
      viewPoint.y += (viewSize.height - imageSize.height * scale) / 2.0
    when UIViewContentModeScaleAspectFill
      scale = MAX(ratioX, ratioY)
      viewPoint.x *= scale
      viewPoint.y *= scale
      viewPoint.x += (viewSize.width  - imageSize.width  * scale) / 2.0
      viewPoint.y += (viewSize.height - imageSize.height * scale) / 2.0
    when UIViewContentModeCenter
      viewPoint.x += viewSize.width / 2.0  - imageSize.width  / 2.0
      viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0
    when UIViewContentModeTop
      viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0
    when UIViewContentModeBottom
      viewPoint.x += viewSize.width / 2.0 - imageSize.width / 2.0
      viewPoint.y += viewSize.height - imageSize.height
    when UIViewContentModeLeft
      viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0
    when UIViewContentModeRight
      viewPoint.x += viewSize.width - imageSize.width
      viewPoint.y += viewSize.height / 2.0 - imageSize.height / 2.0
    when UIViewContentModeTopRight
      viewPoint.x += viewSize.width - imageSize.width
    when UIViewContentModeBottomLeft
      viewPoint.y += viewSize.height - imageSize.height
    when UIViewContentModeBottomRight
      viewPoint.x += viewSize.width  - imageSize.width
      viewPoint.y += viewSize.height - imageSize.height
    when UIViewContentModeTopLeft  # go to next label.
    else
    end

    viewPoint
  end

  def convertPointFromViewArea(point)
    dp "convertPointFromViewArea:point=#{NSStringFromCGPoint(point)}"

    return CGPointZero unless self.image

    imagePoint = point
    imageSize = self.image.size
    viewSize  = self.bounds.size
    ratioX = viewSize.width / imageSize.width
    ratioY = viewSize.height / imageSize.height
    scale = 0.0

    case self.contentMode
    when UIViewContentModeScaleToFill  # go to next label.
    when UIViewContentModeRedraw
      imagePoint.x /= ratioX
      imagePoint.y /= ratioY
    when UIViewContentModeScaleAspectFit
      scale = MIN(ratioX, ratioY)
      imagePoint.x -= (viewSize.width  - imageSize.width  * scale) / 2.0
      imagePoint.y -= (viewSize.height - imageSize.height * scale) / 2.0
      imagePoint.x /= scale
      imagePoint.y /= scale
    when UIViewContentModeScaleAspectFill
      scale = MAX(ratioX, ratioY)
      imagePoint.x -= (viewSize.width  - imageSize.width  * scale) / 2.0
      imagePoint.y -= (viewSize.height - imageSize.height * scale) / 2.0
      imagePoint.x /= scale
      imagePoint.y /= scale
    when UIViewContentModeCenter
      imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0
      imagePoint.y -= (viewSize.height - imageSize.height) / 2.0
    when UIViewContentModeTop
      imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0
    when UIViewContentModeBottom
      imagePoint.x -= (viewSize.width - imageSize.width)  / 2.0
      imagePoint.y -= (viewSize.height - imageSize.height)
    when UIViewContentModeLeft
      imagePoint.y -= (viewSize.height - imageSize.height) / 2.0
    when UIViewContentModeRight
      imagePoint.x -= (viewSize.width - imageSize.width)
      imagePoint.y -= (viewSize.height - imageSize.height) / 2.0
    when UIViewContentModeTopRight
      imagePoint.x -= (viewSize.width - imageSize.width)
    when UIViewContentModeBottomLeft
      imagePoint.y -= (viewSize.height - imageSize.height)
    when UIViewContentModeBottomRight
      imagePoint.x -= (viewSize.width - imageSize.width)
      imagePoint.y -= (viewSize.height - imageSize.height)
    when UIViewContentModeTopLeft    # go to next label.
    else
    end

    imagePoint
  end

  def convertRectFromImageArea(rect)
    dp "rect=#{NSStringFromCGRect(rect)}"

    return CGRectZero unless self.image

    imageTopLeft = rect.origin
    imageBottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))

    viewTopLeft = self.convertPointFromImageArea(imageTopLeft)
    viewBottomRight = self.convertPointFromImageArea(imageBottomRight)

    viewWidth = (viewBottomRight.x - viewTopLeft.x).abs
    viewHeight = (viewBottomRight.y - viewTopLeft.y).abs
    viewRect = CGRectMake(viewTopLeft.x, viewTopLeft.y, viewWidth, viewHeight)

    viewRect
  end

  def convertRectFromViewArea(rect)
    dp "rect=#{NSStringFromCGRect(rect)}"

    return CGRectZero unless self.image

    viewTopLeft = rect.origin
    viewBottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))

    imageTopLeft = self.convertPointFromViewArea(viewTopLeft)
    imageBottomRight = self.convertPointFromViewArea(viewBottomRight)

    imageWidth = (imageBottomRight.x - imageTopLeft.x).abs
    imageHeight = (imageBottomRight.y - imageTopLeft.y).abs
    imageRect = CGRectMake(imageTopLeft.x, imageTopLeft.y, imageWidth, imageHeight)

    imageRect
  end

  def hideFocusFrame(animated)
    # [@focusFrameHideTimer invalidate]
    @focusFrameHideTimer = nil

    unless animated
      CATransaction.begin
      CATransaction.setValue(KCFBooleanTrue, forKey:KCATransactionDisableActions)
    end
    @focusFrameLayer.opacity = 0.0
    @showingFocusFrame = false
    CATransaction.commit unless animated
  end

  def showFocusFrame(rect, status:status, animated:animated)
    dp "rect=#{NSStringFromCGRect(rect)}, status=#{status}"
    self.showFocusFrame(rect, status:status, duration:0.0, animated:animated)
  end

  def showFocusFrame(rect, status:status, duration:duration, animated:animated)
    dp "rect=#{NSStringFromCGRect(rect)}, status=#{status}, duration=#{duration}"

    # [@focusFrameHideTimer invalidate]
    @focusFrameHideTimer = nil

    return unless self.image

    rectOnImage = OLYCameraConvertRectOnViewfinderIntoLiveImage(rect, self.image)
    # @FIXME ここむりやりつじつま合わせている
    scale = self.frame.size.width / self.image.size.width
    dp "★scale=#{scale}"
    rectOnFrame = CGRectMake(rectOnImage.origin.x * scale, rectOnImage.origin.y * scale, rectOnImage.size.width * scale, rectOnImage.size.height * scale)
    rectOnImageView = self.convertRectFromImageArea(rectOnFrame)
    frameColorRef = nil
    frameColorRef = case status
    when 'RecordingCameraLiveImageViewStatusRunning'
      @focusFrameBorderColorStatusRunning.CGColor
    when 'RecordingCameraLiveImageViewStatusLocked'
      @focusFrameBorderColorStatusLocked.CGColor
    when 'RecordingCameraLiveImageViewStatusFailed'
      @focusFrameBorderColorStatusFailed.CGColor
    end
    unless animated
      CATransaction.begin
      CATransaction.setValue(KCFBooleanTrue, forKey:KCATransactionDisableActions)
    end
    @focusFrameRect = rect
    @focusFrameLayer.borderColor = frameColorRef
    @focusFrameLayer.frame = rectOnImageView
    @focusFrameLayer.opacity = @focusFrameBorderOpacity
    CATransaction.commit unless animated

    @focusFrameStatus = status
    @showingFocusFrame = true

    if duration > 0
      @focusFrameHideTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target:self, selector:'didFireFocusFrameHideTimer:', userInfo:nil, repeats:false)
    end
  end

  def changeFocusFrameStatus(status, animated:animated)
    dp "status=#{status}"

    return unless self.image

    frameColorRef = nil
    case status
    when 'RecordingCameraLiveImageViewStatusRunning'
      frameColorRef = @focusFrameBorderColorStatusRunning.CGColor
    when 'RecordingCameraLiveImageViewStatusLocked'
      frameColorRef = @focusFrameBorderColorStatusLocked.CGColor
    when 'RecordingCameraLiveImageViewStatusFailed'
      frameColorRef = @focusFrameBorderColorStatusFailed.CGColor
    end
    unless animated
      CATransaction.begin
      CATransaction.setValue(KCFBooleanTrue, forKey:KCATransactionDisableActions)
    end
    @focusFrameLayer.borderColor = frameColorRef
    CATransaction.commit unless animated

    @focusFrameStatus = status
  end

  def showFocusFrame(rect, status:status, animated:animated)
    dp "rect=#{NSStringFromCGRect(rect)}, status=#{status}"
    self.showFocusFrame(rect, status:status, duration:0.0, animated:animated)
  end


end
