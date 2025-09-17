class Userinfo < ApplicationRecord
  has_and_belongs_to_many :dandelions
  has_many :file_records
end
