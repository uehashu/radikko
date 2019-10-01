class CreateAreas < ActiveRecord::Migration[4.2]
  def change
    create_table :areas, id: false do |t|
      t.string :area_id
      t.string :area_name
      t.string :area_name_kana

      #t.timestamps null: false
    end
    
    add_index :areas, :area_id, unique: true
    
  end
end
