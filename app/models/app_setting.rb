class AppSetting
  attr_accessor :bluetoothLocalName, :bluetoothPasscode

  # Rubymotionではシングルトンモジュールが使えない
  def self.instance
    Dispatch.once { @@instance ||= NSUserDefaults.standardUserDefaults }
    @@instance
  end

end
