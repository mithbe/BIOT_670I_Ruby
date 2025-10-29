class Userinfo < ApplicationRecord
  # Connects userinfo records to multiple dandelions
  has_and_belongs_to_many :dandelions
end
