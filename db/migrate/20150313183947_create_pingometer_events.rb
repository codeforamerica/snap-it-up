class CreatePingometerEvents < ActiveRecord::Migration
  def change
    create_table :pingometer_events do |t|
      t.references :incident, index: true
      t.string :status
      t.datetime :triggered_at

      t.timestamps null: false
    end
    add_foreign_key :pingometer_events, :incidents
  end
end
