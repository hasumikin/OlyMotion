class PanelView < UIView
  include DebugConcern

  def initWithFrame(frame)
    super(frame)
    self.backgroundColor = UIColor.grayColor
    @container = []
    @button = []
    6.times do |i|
      @container << UIView.new
      @button[i] = []
    end
    ('Ａ'..'Ｌ').each_with_index do |label, index|
      @button[index / 2] << UIButton.rounded_rect.tap do |b|
        b.setTitle(label, forState:UIControlStateNormal)
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter
        b.on(:touch) { |event| closePhotoView }
      end
    end

    panelWidth = Device.screen.width - Device.screen.height * 1.5
    buttonWidth = (panelWidth - 10 -10 - 15) / 2
    6.times do |index|
      @container[index] << @button[index][0]
      @container[index] << @button[index][1]
      Motion::Layout.new do |layout|
        layout.view @container[index]
        layout.subviews button0: @button[index][0], button1: @button[index][1]
        layout.vertical "|[button0]|"
        layout.vertical "|[button1]|"
        layout.horizontal "|-10-[button0(#{buttonWidth})]-15-[button1(#{buttonWidth})]-10-|"
      end
      self << @container[index]
    end

    @releaseButton = UIButton.buttonWithType(UIButtonTypeSystem)
    @releaseButton.setTitle("写", forState:UIControlStateNormal)
    @releaseButton.addTarget(self, action:"releaseShutter", forControlEvents:UIControlEventTouchUpInside)
    self << @releaseButton

    Motion::Layout.new do |layout|
      layout.view self
      layout.subviews releaseButton: @releaseButton, ab: @container[0], cd: @container[1], ef: @container[2], gh: @container[3], ij: @container[4], kl: @container[5]
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
