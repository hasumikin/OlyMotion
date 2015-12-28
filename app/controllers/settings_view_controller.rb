class SettingsViewController < UIViewController

  def viewDidLoad
    super

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    # @table.rowHeight = 80
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

    @data = []
    @data << { label: 'Bluetooth', detail: '$bluetoothLocalName' }
    @data << { label: 'Wi-Fi',     detail: '$ssid' }
  end

  # UITableView に必須のメソッド
  def tableView(tableView, numberOfRowsInSection: section)
    @data.size
  end

  # UITableView に必須のメソッド
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @reuseIdentifier ||= "CELL_IDENTIFIER"
    cell = tableView.dequeueReusableCellWithIdentifier(@reuseIdentifier) || begin
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:@reuseIdentifier)
    end
    # ↑ここまではお決まりのコード
    # ↓ここでテーブルにデータを入れる
    cell.textLabel.text = @data[indexPath.row][:label]
    cell.detailTextLabel.text = @data[indexPath.row][:detail]

    cell
  end

end
