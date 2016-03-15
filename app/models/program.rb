class Program < ActiveRecord::Base
  
  # searching method
  def self.search(search_word = nil)
    unless search_word.blank?
      where("title like ? or subtitle like ? or performers like ?",
           "%" + search_word + "%",
           "%" + search_word + "%",
           "%" + search_word + "%")
    else
      all
    end
  end
end
