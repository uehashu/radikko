class Configure < ActiveRecord::Base
  validates :key, uniqueness: true
end
