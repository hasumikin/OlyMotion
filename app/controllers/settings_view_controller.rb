class SettingsViewController < UIViewController

  BluetoothConnectionChangedNotification = "BluetoothConnectionChangedNotification"

  def viewDidLoad
    super

    @setting = AppSetting.instance

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self

    Motion::Layout.new do |layout|
      layout.view self.view
      layout.subviews table: @table
      layout.vertical "|[table]|"
      layout.horizontal "|[table]|"
    end

    @table_data = [
      { title: 'Access Method',
        rows: [
          { label: 'Bluetooth', detail: '$bluetoothLocalName', accessory_type: UITableViewCellAccessoryDisclosureIndicator },
          { label: 'Wi-Fi',     detail: '$ssid', accessory_type: UITableViewCellAccessoryNone }
        ]
      },
      { title: 'Connection',
        rows: [
          { label: 'Connect with Bluetooth', detail: '', accessory_type: UITableViewCellAccessoryNone },
          { label: 'Connect with Wi-Fi',     detail: '', accessory_type: UITableViewCellAccessoryNone }
        ]
      }
    ]

    # @bluetoothConnector = BluetoothConnector.new
    # notificationCenter.addObserver(self, selector:'didChangeBluetoothConnection:', name:BluetoothConnectionChangedNotification, object:nil)
  end

  def viewWillAppear(animated)
    super

    @table_data[0][:rows][0][:detail] = @setting['bluetoothLocalName']
    @table.reloadData
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self, name: BluetoothConnectionChangedNotification, object:nil)
  end

  # dataSource = self に必須のメソッド1/2
  def tableView(tableView, numberOfRowsInSection: section)
    @table_data[section][:rows].size
  end

  # dataSource = self に必須のメソッド2/2
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end
    # ↑ここまではお決まりのコード
    # ↓ここでテーブルにデータを入れる
    row = @table_data[indexPath.section][:rows][indexPath.row]
    cell.textLabel.text       = row[:label]
    cell.detailTextLabel.text = row[:detail]
    cell.accessoryType        = row[:accessory_type]
    # ↓セルを返す。本メソッドの末尾にこれが必須
    cell
  end

  #セクションの数
  def numberOfSectionsInTableView(tableView)
    @table_data.size
  end

  # セクションのタイトル
  def tableView(tableView, titleForHeaderInSection: section)
    @table_data[section][:title]
  end

  # テーブルの行がタップされた
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    case @table_data[indexPath.section][:rows][indexPath.row][:label]
    when 'Bluetooth'
      BluetoothViewController.new.tap do |controller|
        self.navigationController.pushViewController(controller, animated:true)
      end
    end
  end

end
