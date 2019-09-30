class Configure < ApplicationRecord
  validates :key, uniqueness: true
end
