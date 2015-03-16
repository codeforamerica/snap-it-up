class AddRawMonitorToWebService < ActiveRecord::Migration
  def change
    add_column :web_services, :raw_monitor_data, :jsonb
  end
end
