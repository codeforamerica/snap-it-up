class CreateMonitorIncidents < ActiveRecord::Migration
  def change
    create_table :monitor_incidents do |t|
      t.references :web_service, index: true
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps null: false
    end
    add_foreign_key :monitor_incidents, :web_services
  end
end
