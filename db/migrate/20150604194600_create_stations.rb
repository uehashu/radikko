class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :station_id
      t.string :station_name
      t.string :station_name_ascii
      t.string :area_id
    end

    add_index :stations, :station_id, unique: true
    
  end
end
