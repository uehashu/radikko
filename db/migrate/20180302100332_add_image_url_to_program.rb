class AddImageUrlToProgram < ActiveRecord::Migration
  def change
    add_column :programs, :image_url, :string, :null => true
  end
end
