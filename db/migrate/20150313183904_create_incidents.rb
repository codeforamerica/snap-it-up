class CreateIncidents < ActiveRecord::Migration
  def change
    create_table :incidents do |t|
      t.references :pingometer_monitor, index: true
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps null: false
    end
    add_foreign_key :incidents, :pingometer_monitors
  end
end
