class SettingsTableView < UIView

  include DebugConcern

  attr_accessor :table, :refreshControl

  def initialize(settingsTable)
    @settingsTable = settingsTable
    @table = UITableView.alloc.initWithFrame(CGRectMake(0, 0, 0, 0), style:UITableViewStylePlain)
    @refreshControl = UIRefreshControl.new
    @table << @refreshControl

    initWithFrame(CGRectMake(0, 0, 0, 0))
    self << @table
  end

  def layoutSubviews
    super
    @table.frame = self.frame
  end

end
