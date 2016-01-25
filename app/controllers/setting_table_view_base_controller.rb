class SettingTableViewBaseController < UIViewController

  include DebugConcern

  def viewDidLoad
    @title ||= 'N/A'
    super

    @setting = AppSetting.instance
    @bluetoothLocalName = nil
    @bluetoothPasscode = nil

    self.title = @title
    self.view.backgroundColor = UIColor.blueColor

    menu_button = BW::UIBarButtonItem.styled(:plain, 'Done') { close }
    self.navigationItem.RightBarButtonItem = menu_button;

    @table = UITableView.alloc.initWithFrame(self.view.bounds)
    @table.autoresizingMask = UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@table)
    @table.dataSource = self
    @table.delegate = self

    Motion::Layout.new do |layout|
      layout.view self.view
      layout.subviews table: @table
      layout.vertical "[table]"
      layout.horizontal "[table]"
    end
  end

  # Doneが押された
  def close
    save_defaults
    self.navigationController.popViewControllerAnimated(true)
  end

  def save_defaults
    # 各クラスでオーバライド
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

end
