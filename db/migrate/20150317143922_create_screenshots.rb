class CreateScreenshots < ActiveRecord::Migration
  def change
    create_table :screenshots do |t|
      t.references :pingometer_monitor, index: true
      t.references :pingometer_event, index: true
      t.string :image_id

      t.timestamps null: false
    end
    add_foreign_key :screenshots, :pingometer_monitors
    add_foreign_key :screenshots, :pingometer_events
  end
end
