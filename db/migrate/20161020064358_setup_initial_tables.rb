class SetupInitialTables < ActiveRecord::Migration[5.0]
  def change
    create_table :incidents do |t|
      t.string :monitor
      t.string :state
      t.datetime :start_date
      t.datetime :end_date
      t.integer :milliseconds, limit: 8
      t.boolean :accepted, default: true
      
      t.timestamps
    end
    
    create_table :monitor_events do |t|
      t.belongs_to :incident, index: true
      t.string :pingometer_id
      t.string :monitor
      t.integer :status, null: false
      t.datetime :date, null: false
      t.string :state
      t.boolean :accepted, default: true
      
      t.timestamps
    end
 
    create_table :snapshots do |t|
      t.belongs_to :event, foreign_key: {to_table: :monitor_events}
      t.string :monitor
      t.string :status
      t.datetime :date, null: false
      t.string :name, null: false
      t.string :url
      t.string :state
      
      t.timestamps
    end
  end
end
