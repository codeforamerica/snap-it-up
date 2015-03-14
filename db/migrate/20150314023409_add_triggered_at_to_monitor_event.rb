class AddTriggeredAtToMonitorEvent < ActiveRecord::Migration
  def change
    add_column :monitor_events, :triggered_at, :datetime, null: false
  end
end
