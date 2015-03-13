class CreateWebServices < ActiveRecord::Migration
  def change
    create_table :web_services do |t|
      t.string :pingometer_id

      t.timestamps null: false
    end
  end
end
