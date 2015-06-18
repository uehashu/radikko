class CreateStations < ActiveRecord::Migration
  def change
    add_index :stations, :station_id, unique: true
    
    create_table :stations do |t|
      t.string :station_id
      t.string :station_name
      t.string :station_name_ascii
      t.string :area_id
    end
  end
end
