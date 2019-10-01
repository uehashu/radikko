class CreateConfigures < ActiveRecord::Migration[4.2]
  def change
    create_table :configures do |t|
      t.string :key
      t.string :value

      t.timestamps null: false
    end

    add_index :configures, :key, unique: true
  end
end
