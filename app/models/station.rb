class Station < ActiveRecord::Base
  
  def to_param
    "#{station_id}"
  end
end
