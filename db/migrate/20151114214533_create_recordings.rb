class CreateRecordings < ActiveRecord::Migration[4.2]
  def change
    create_table :recordings do |t|
      t.integer :area_id
      t.string :station_id
      t.datetime :start_datetime
      t.integer :recording_second
      t.string :title
      t.string :filename
      t.string :job_id
      t.boolean :is_recorded

      t.timestamps null: false
    end
  end
end
