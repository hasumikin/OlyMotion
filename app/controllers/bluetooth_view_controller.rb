class BluetoothViewController < SettingTableViewBaseController

  def viewDidLoad
    @title = 'Bluetooth'
    super

    @table_data = [
      { title: '',
        rows: [
          { label: 'Local Name', detail: @setting['bluetoothLocalName'], accessory_type: UITableViewCellAccessoryNone },
          { label: 'Password',     detail: convert_secure(@setting['bluetoothPasscode']), accessory_type: UITableViewCellAccessoryNone }
        ]
      },
      { title: 'Autocompletion',
        rows: [
          { label: 'Get from OA.Central', detail: '', accessory_type: UITableViewCellAccessoryDisclosureIndicator }
        ]
      }
    ]

    # OA.Centralから接続設定を取得したかを監視
    # tip : 'didGetAppOACentralConfiguration:' の末尾の「:」がミソです。同メソッドが引数を必要としているため、「:」を書かないとNSInvalidArgumentExceptionが発生します
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'didGetAppOACentralConfiguration:', name: AppDelegate::AppOACentralConfigurationDidGetNotification, object:nil)
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = super(tableView, cellForRowAtIndexPath: indexPath)
    row = @table_data[indexPath.section][:rows][indexPath.row]
    cell.textLabel.text       = row[:label]
    cell.detailTextLabel.text = row[:detail]
    cell.accessoryType        = row[:accessory_type]
    # ↓セルを返す。本メソッドの末尾にこれが必須
    cell
  end

  # テーブルの行がタップされた
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    case @table_data[indexPath.section][:rows][indexPath.row][:label]
    when 'Get from OA.Central'
      getFromOacentral
    end
  end

  def save_defaults
    @setting['bluetoothLocalName'] = @bluetoothLocalName
    @setting['bluetoothPasscode']  = @bluetoothPasscode
  end

  def didGetAppOACentralConfiguration(notification)
    dp "notification=#{notification}"
    # OA.Centralから取得した接続設定を現在のBluetooth接続の設定値に入力
    configuration = notification.userInfo[AppDelegate::AppOACentralConfigurationDidGetNotificationUserInfo]
    @bluetoothLocalName = configuration.bleName
    @bluetoothPasscode = configuration.bleCode
    @table_data[0][:rows][0][:detail] = configuration.bleName
    @table_data[0][:rows][1][:detail] = convert_secure(configuration.bleCode)
    @table.reloadData
  end

  def convert_secure(text)
    text ? '●' * text.size : ''
  end

  def dealloc
    # OA.Centralから接続設定を取得したかの監視を終了
    NSNotificationCenter.defaultCenter.removeObserver(self, name: AppDelegate::AppOACentralConfigurationDidGetNotification, object:nil)
  end

  def getFromOacentral
    # キーボード閉じる
    self.view.endEditing(true)

    # OA.Centralに設定情報を要求
    unless OACentralConfiguration.requestConfigurationURL(AppDelegate::AppUrlSchemeGetFromOacentral)
      # OA.Centralの呼び出しに失敗
      App.alert "CouldNotOpenOACentralByNotInstalled"
    end
  end

end
