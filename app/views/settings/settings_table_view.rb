class SettingsTableView < UIView

  include DebugConcern

  attr_accessor :table

  def initialize(settingsTable)
    @table = UITableView.alloc.initWithFrame(CGRectMake(0, 0, 0, 0), style:UITableViewStylePlain);
    @refreshControl = UIRefreshControl.new
    @table.addSubview(@refreshControl)

    initWithFrame(CGRectMake(0, 0, 0, 0))
    self << @table
  end

  def layoutSubviews
    super
    @table.frame = self.frame
  end

end
