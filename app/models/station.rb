class Station < ApplicationRecord
  
  def to_param
    "#{station_id}"
  end
end
