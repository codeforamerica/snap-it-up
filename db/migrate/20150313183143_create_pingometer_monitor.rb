class CreatePingometerMonitor < ActiveRecord::Migration
  def change
    create_table :pingometer_monitors do |t|
      t.string :pingometer_id
      t.string :hostname
      t.jsonb :raw_data

      t.timestamps null: false
    end

    add_index :pingometer_monitors, :pingometer_id, unique: true
    add_index :pingometer_monitors, :hostname, unique: true
  end
end
