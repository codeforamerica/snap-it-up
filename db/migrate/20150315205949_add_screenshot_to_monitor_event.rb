class AddScreenshotToMonitorEvent < ActiveRecord::Migration
  def change
    add_column :pingometer_events, :screenshot_id, :string
    add_column :pingometer_events, :screenshot_at, :datetime
  end
end
