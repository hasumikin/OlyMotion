class AppCamera
  attr_reader :connected, :connectionType

  # Rubymotionではシングルトンモジュールが使えない
  def self.instance
    Dispatch.once { @@instance ||= new }
    @@instance
  end

  def initialize
    @connected = false
    @connectionType = nil
  end

end
