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
  end

  # UITableView に必須のメソッド
  def tableView(tableView, numberOfRowsInSection: section)
    0
  end

  # UITableView に必須のメソッド
  def tableView(tableView, cellForRowAtIndexPath: indexPath)
  end

end
