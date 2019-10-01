class CreatePrograms < ActiveRecord::Migration[4.2]
  def change
    create_table :programs do |t|
      t.string :station_id
      t.datetime :start_date
      t.datetime :end_date
      t.integer :duration_sec
      t.string :title
      t.string :subtitle
      t.string :performers
      t.text :description
      t.string :reserved

      t.timestamps null: false
    end
  end
end
