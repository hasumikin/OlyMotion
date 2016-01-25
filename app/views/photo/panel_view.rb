class PanelView < UIView
  include DebugConcern

  COMPONENTS = [
    { # A 0 / 0
      uiType: :button,
      title: '☓',
      action: :closePhotoView,
      outlet: :closePhotoViewButton
    },
    { # B 0 / 1
      uiType: :label,
      text: 'alert',
      outlet: :alertLabel
    },
    { # C 1 / 0
      uiType: :button,
      title: "WB\nAuto",
      action: :toggleWhiteBalance,
      outlet: :toggleWhiteBalanceButton
    },
    { # D 1 / 1
      uiType: :button,
      title: 'P',
      action: :toggleTakeMode,
      outlet: :toggleTakeModeButton
    },
    { # E 2 / 0
      uiType: :label,
      text: "SHTR\nN/A",
      outlet: :shutterSpeedLabel
    },
    { # F 2 / 1
      uiType: :label,
      text: "ISO\nN/A",
      outlet: :isoSensitivityLabel
    },
    { # G 3 / 0
      uiType: :button,
      title: 'S-AF',
      action: :toggleFocusMode,
      outlet: :toggleFocusModeButton
    },
    { # H 3 / 1
      uiType: :button,
      title: "AE\nUnlock",
      action: :toggleAeLockState,
      outlet: :toggleAeLockStateButton
    },
    { # I
      uiType: :label,
      text: '25mm',
      outlet: :focusLengthLabel
    },
    { # J
      uiType: :label,
      text: '300mm',
      outlet: :focusLengthLabel2
    },
    { # K
      uiType: :label,
      text: "APTR\nN/A",
      outlet: :apertureValueLabel
    },
    { # L
      uiType: :label,
      text: "XPSR\nN/A",
      outlet: :exposureCompensationLabel
    }
  ]

  def initWithFrame(frame)
    super(frame)
    @camera = AppCamera.instance
    @outlets = {}
    self.backgroundColor = UIColor.darkGrayColor
    @containers = []
    @components = []
    6.times do |i|
      @containers << UIView.new
      @components[i] = []
    end
    COMPONENTS.each_with_index do |component, index|
      @outlets[component[:outlet]] = case component[:uiType]
      when :button
        UIButton.rounded_rect.tap do |b|
          b.titleLabel.numberOfLines = 0
          b.setTitle(component[:title], forState:UIControlStateNormal)
          b.titleLabel.textAlignment = NSTextAlignmentCenter
          # b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter
          b.on(:touch) { |event| send(component[:action]) }
        end
      when :label
        UILabel.new.tap do |l|
          l.numberOfLines = 0
          l.font = UIFont.systemFontOfSize(14)
          l.text = component[:text]
          l.textAlignment = NSTextAlignmentCenter
          l.textColor = UIColor.whiteColor
        end
      end
      @components[index / 2] << @outlets[component[:outlet]]
    end

    panelWidth = Device.screen.width - Device.screen.height * 1.5
    componentWidth = (panelWidth - 2 - 2 - 2) / 2
    6.times do |index|
      @containers[index] << @components[index][0]
      @containers[index] << @components[index][1]
      Motion::Layout.new do |layout|
        layout.view @containers[index]
        layout.subviews component0: @components[index][0], component1: @components[index][1]
        layout.vertical "|[component0]|"
        layout.vertical "|[component1]|"
        layout.horizontal "|-2-[component0(#{componentWidth})]-2-[component1(#{componentWidth})]-2-|"
      end
      self << @containers[index]
    end

    @releaseButton = UIButton.buttonWithType(UIButtonTypeSystem)
    @releaseButton.setTitle("写", forState:UIControlStateNormal)
    @releaseButton.addTarget(self, action:"releaseShutter", forControlEvents:UIControlEventTouchUpInside)
    self << @releaseButton

    Motion::Layout.new do |layout|
      layout.view self
      layout.subviews releaseButton: @releaseButton, ab: @containers[0], cd: @containers[1], ef: @containers[2], gh: @containers[3], ij: @containers[4], kl: @containers[5]
      layout.vertical "|[ab][cd(==ab)][ef(==ab)]-[releaseButton(==ab)]-[gh(==ab)][ij(==ab)][kl(==ab)]|"
      layout.horizontal "|[ab]|"
      layout.horizontal "|[cd]|"
      layout.horizontal "|[ef]|"
      layout.horizontal "|[releaseButton]|"
      layout.horizontal "|[gh]|"
      layout.horizontal "|[ij]|"
      layout.horizontal "|[kl]|"
    end

    self
  end

  def releaseShutter
  end

  def closePhotoView
    NSNotificationCenter.defaultCenter.postNotificationName('PhotoViewCloseButtonWasTapped', object:self)
  end

  def updateApertureValueLabel
    actualApertureValue = @camera.actualApertureValue.match(/<APERTURE\/([^>]+)>/).try(:[], 1)
    @outlets[:apertureValueLabel].text = actualApertureValue ? "APTR\n#{actualApertureValue}" : "APTR\nN/A"
  end

  def updateShutterSpeedLabel
    actualShutterSpeed = @camera.actualShutterSpeed.match(/<SHUTTER\/([^>]+)>/).try(:[], 1)
    @outlets[:shutterSpeedLabel].text = actualShutterSpeed ? "SHTR\n#{actualShutterSpeed}" : "SHTR\nN/A"
  end

  def updateExposureCompensationLabel
    actualExposureCompensation = @camera.actualExposureCompensation.match(/<EXPREV\/([^>]+)>/).try(:[], 1)
    @outlets[:exposureCompensationLabel].text = actualExposureCompensation ? "XPSR\n#{actualExposureCompensation}" : "XPSR\nN/A"
  end

  def updateIsoSensitivityLabel
    actualIsoSensitivity = @camera.actualIsoSensitivity.match(/<ISO\/([^>]+)>/).try(:[], 1)
    @outlets[:isoSensitivityLabel].text = actualIsoSensitivity ? "ISO\n#{actualIsoSensitivity}" : "ISO\nN/A"
  end

  def updateToggler(key, index)
    @outlets[key].setTitle(PhotoViewController::TOGGLERS[key][:titles][index], forState:UIControlStateNormal)
  end

  def toggleFocusMode
    NSNotificationCenter.defaultCenter.postNotificationName('ToggleFocusModeButtonWasTapped', object:self)
  end

  def toggleWhiteBalance
    NSNotificationCenter.defaultCenter.postNotificationName('ToggleWhiteBalanceButtonWasTapped', object:self)
  end

  def toggleTakeMode
    NSNotificationCenter.defaultCenter.postNotificationName('ToggleTakeModeButtonWasTapped', object:self)
  end

  def toggleAeLockState
    NSNotificationCenter.defaultCenter.postNotificationName('ToggleAeLockStateButtonWasTapped', object:self)
  end

end
