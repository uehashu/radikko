class RemoveSubtitleFromPrograms < ActiveRecord::Migration
  def change
    remove_column :programs, :subtitle, :string
  end
end
