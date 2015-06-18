class Station < ActiveRecord::Base
  validates :station_id, uniqueness: true
  
  def to_param
    "#{station_id}"
  end
end
