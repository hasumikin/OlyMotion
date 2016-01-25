class MagnifyingLiveViewScaleViewController < SettingTableViewBaseController

  def viewDidLoad
    @title = 'Magnifying Live View Scale'
    super

    @table_data = [
      { title: '',
        rows: []
      }
    ]
    AppCamera::MAGNIFYING_LIVE_VIEW_SCALES.each do |key, value|
      @table_data[0][:rows] << {
        label: value,
        detail: '',
        accessory_type: (@setting['magnifingLiveViewScale'] == key ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone)
      }
    end
 end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = super(tableView, cellForRowAtIndexPath: indexPath)
    row = @table_data[indexPath.section][:rows][indexPath.row]
    cell.textLabel.text       = row[:label]
    cell.detailTextLabel.text = row[:detail]
    cell.accessoryType        = row[:accessory_type]
    cell
  end

  # テーブルの行がタップされた
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    @table_data[0][:rows].each_with_index do |row, index|
      row[:accessory_type] = if index == indexPath.row
        UITableViewCellAccessoryCheckmark
      else
        UITableViewCellAccessoryNone
      end
    end
    @table.reloadData
  end

  def save_defaults
    if row = @table_data[0][:rows].find{ |h| h.value?(UITableViewCellAccessoryCheckmark) }
      @setting['magnifingLiveViewScale'] = AppCamera::MAGNIFYING_LIVE_VIEW_SCALES.index(row[:label])
    end
  end

end
