class SettingsTable

  include DebugConcern

  attr_accessor :data, :showWifiSettingCell

  def initialize
    @camera = AppCamera.instance
    @setting = AppSetting.instance
    @data = [
      { title: 'Access Method',
        rows: [
          { label: 'Bluetooth',
            detail: '$bluetoothLocalName',
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            outlet: :@showBluetoothSettingCell
          },
          { label: 'Wi-Fi',
            detail: '$ssid',
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            outlet: :@showWifiSettingCell
          }
        ]
      },
      { title: 'Connection',
        rows: [
          { label: 'Connect with Bluetooth',
            detail: '',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@connectWithUsingBluetoothCell
          },
          { label: 'Connect with Wi-Fi',
            detail: '',
            accessory_type: UITableViewCellAccessoryDisclosureIndicator,
            outlet: :@connectWithUsingWifiCell
          },
          { label: 'Disconnect',
            detail: '',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@disconnectCell
          },
          { label: 'Disconnect and Sleep',
            detail: '',
            accessory_type: UITableViewCellAccessoryNone,
            outlet: :@disconnectAndSleepCell
          }
        ]
      }
    ]
  end

  # dataSourceメソッド1/2
  def tableView(tableView, numberOfRowsInSection: section)
    @data[section][:rows].size
  end

  # dataSourceメソッド2/2
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end
    # ↑ここまではお決まりのコード
    # ↓ここでテーブルにデータを入れる
    row = @data[indexPath.section][:rows][indexPath.row]
    instance_variable_set(row[:outlet], cell) if row[:outlet]
    cell.textLabel.text       = row[:label]
    cell.detailTextLabel.text = row[:detail]
    cell.accessoryType        = row[:accessory_type]
    # ↓セルを返す。本メソッドの末尾にこれが必須
    cell
  end

  #セクションの数
  def numberOfSectionsInTableView(tableView)
    @data.size
  end

  # セクションのタイトル
  def tableView(tableView, titleForHeaderInSection: section)
    @data[section][:title]
  end

  def updateCell(cell, enable, accessoryType = nil)
    if cell
      cell.userInteractionEnabled  = enable unless enable.nil?
      cell.textLabel.enabled       = enable unless enable.nil?
      cell.detailTextLabel.enabled = enable unless enable.nil?
      cell.accessoryType    = accessoryType if accessoryType
    else
      dp "cellがnil？"
    end
  end

  # Wi-Fi接続の状態を表示します。
  def updateShowWifiSettingCell(wifiConnector)
    return nil unless @showWifiSettingCell
    @showWifiSettingCell.detailTextLabel.text = case wifiConnector.connectionStatus
    when 'WifiConnectionStatusConnected'
      # 接続されている場合はそのSSIDを表示します。
      case wifiConnector.cameraStatus
      when 'WifiCameraStatusReachable'
        wifiConnector.ssid ? wifiConnector.ssid : "WifiConnected(null)"
      when 'WifiCameraStatusUnreachable1'
        wifiConnector.ssid ? "WifiNotConnected1(#{wifiConnector.ssid})" : "WifiNotConnected1(null)"
      when 'WifiCameraStatusUnreachable2'
        wifiConnector.ssid ? "WifiNotConnected2(#{wifiConnector.ssid})" : "WifiNotConnected2(null)"
      else
        "WifiStatusUnknown1" # Wi-Fi接続済みで接続先は確認中
      end
    when 'WifiConnectionStatusNotConnected'
      "WifiNotConnected"
    else
      "WifiStatusUnknown2"
    end
    @showWifiSettingCell.userInteractionEnabled = true
  end

  def updateShowBluetoothSettingCell
    @showBluetoothSettingCell.detailTextLabel.text = @setting['bluetoothLocalName'] if @showBluetoothSettingCell
  end

  # アプリ接続の状態を画面に表示します。
  def updateCameraConnectionCells(wifiConnector, bluetoothConnector)
    if @camera.connected && @camera.connectionType == OLYCameraConnectionTypeBluetoothLE
      dp "Bluetoothで接続中です。"
      updateCell(@connectWithUsingBluetoothCell, false, UITableViewCellAccessoryCheckmark)
      updateCell(@connectWithUsingWiFiCell, false, UITableViewCellAccessoryNone)
      updateCell(@disconnectCell, true)
      updateCell(@disconnectAndSleepCell, true)
    elsif @camera.connected && @camera.connectionType == OLYCameraConnectionTypeWiFi
      dp "Wi-Fiで接続中です。"
      updateCell(@connectWithUsingBluetoothCell, false, UITableViewCellAccessoryNone)
      updateCell(@connectWithUsingWiFiCell, false, UITableViewCellAccessoryCheckmark)
      updateCell(@disconnectCell, true)
      updateCell(@disconnectAndSleepCell, true)
    else
      dp "未接続です。"
      if bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
        dp "Bluetooth使用可"
        updateCell(@connectWithUsingBluetoothCell, true)
      else
        dp "Bluetooth使用不可"
        updateCell(@connectWithUsingBluetoothCell, false)
      end
      if wifiConnector.connectionStatus == 'WifiConnectionStatusConnected'
        if wifiConnector.cameraStatus == 'WifiCameraStatusReachable'
          dp "Wi-Fi接続済みで接続先はカメラ"
          updateCell(@connectWithUsingWiFiCell, true)
        elsif wifiConnector.cameraStatus == 'WifiCameraStatusUnreachable'
          dp "Wi-Fi接続済みで接続先はカメラではない"
          if bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
            dp "Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし"
            dp "だが、カメラの電源を入れることぐらいはできるかもしれない"
            updateCell(@connectWithUsingWiFiCell, true)
          else
            dp "Wi-Fi接続済みで接続先はカメラ以外なため自動でカメラに接続できる見込みなし"
            updateCell(@connectWithUsingWiFiCell, false)
          end
        else
          dp "Wi-Fi接続済みで接続先は確認中"
          dp "カメラにアクセスできるか否かが確定するまでの間は操作を許可しない"
          updateCell(@connectWithUsingWiFiCell, false)
        end
      else
        if bluetoothConnector.connectionStatus != 'BluetoothConnectionStatusUnknown'
          dp "Wi-Fi未接続でBluetooth経由の電源投入により自動接続できる見込みあり"
          updateCell(@connectWithUsingWiFiCell, true)
        else
          dp "Wi-Fi未接続でBluetooth使用不可なため自動でカメラに接続できる見込みなし"
          updateCell(@connectWithUsingWiFiCell, false)
        end
      end
      updateCell(@disconnectCell, false)
      updateCell(@disconnectAndSleepCell, false)
      updateCell(@connectWithUsingBluetoothCell, nil, UITableViewCellAccessoryNone)
      updateCell(@connectWithUsingWiFiCell, nil, UITableViewCellAccessoryNone)
    end
  end

end