class CreateMonitorEvents < ActiveRecord::Migration
  def change
    create_table :monitor_events do |t|
      t.references :monitor_incident, index: true
      t.string :status

      t.timestamps null: false
    end
    add_foreign_key :monitor_events, :monitor_incidents
  end
end
