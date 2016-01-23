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
      title: 'WB',
      action: :toggleWhiteBalance,
      outlet: :toggleWhiteBalanceButton
    },
    { # D 1 / 1
      uiType: :button,
      title: 'P',
      action: :toggleAEMode,
      outlet: :toggleAEModeButton
    },
    { # E 2 / 0
      uiType: :label,
      text: '10000',
      outlet: :shutterSpeedLabel
    },
    { # F 2 / 1
      uiType: :label,
      text: 'ISO',
      outlet: :isoLabel
    },
    { # G 3 / 0
      uiType: :button,
      title: 'AF',
      action: :toggleFocusMode,
      outlet: :toggleFocusModeButton
    },
    { # H 3 / 1
      uiType: :button,
      title: 'AEL',
      action: :toggleAELock,
      outlet: :toggleAELockButton
    },
    { # I
      uiType: :label,
      text: '25',
      outlet: :focusLengthLabel
    },
    { # J
      uiType: :label,
      text: '300',
      outlet: :focusLengthLabel2
    },
    { # K
      uiType: :label,
      text: '5.6',
      outlet: :apertureLabel
    },
    { # L
      uiType: :label,
      text: '±0',
      outlet: :exposureCorrectLabel
    }
  ]

  def initWithFrame(frame)
    super(frame)
    self.backgroundColor = UIColor.grayColor
    @containers = []
    @components = []
    6.times do |i|
      @containers << UIView.new
      @components[i] = []
    end
    COMPONENTS.each_with_index do |component, index|
      case component[:uiType]
      when :button
        @components[index / 2] << UIButton.rounded_rect.tap do |b|
          b.setTitle(component[:title], forState:UIControlStateNormal)
          b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter
          b.on(:touch) { |event| send(component[:action]) }
        end
      when :label
        @components[index / 2] << UILabel.new.tap do |l|
          l.font = UIFont.systemFontOfSize(12)
          l.text = component[:text]
          # l.alignment = UITextAlignmentCenter
          l.textColor = UIColor.whiteColor
        end
      end
    end

    panelWidth = Device.screen.width - Device.screen.height * 1.5
    componentWidth = (panelWidth - 5 - 5 - 5) / 2
    6.times do |index|
      @containers[index] << @components[index][0]
      @containers[index] << @components[index][1]
      Motion::Layout.new do |layout|
        layout.view @containers[index]
        layout.subviews component0: @components[index][0], component1: @components[index][1]
        layout.vertical "|[component0]|"
        layout.vertical "|[component1]|"
        layout.horizontal "|-5-[component0(#{componentWidth})]-5-[component1(#{componentWidth})]-5-|"
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
    dp '閉じるボタン'
    NSNotificationCenter.defaultCenter.postNotificationName('PhotoViewCloseButtonWasTapped', object:self)
  end

end
