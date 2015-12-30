class AppSetting
  attr_accessor :bluetoothLocalName, :bluetoothPasscode

  UserDefaultsBluetoothLocalName = "BluetoothLocalName"

  # Rubymotionではシングルトンモジュールが使えない
  def self.instance
    Dispatch.once { @@instance ||= NSUserDefaults.standardUserDefaults }
    @@instance
  end

end
