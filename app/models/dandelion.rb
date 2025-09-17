class Dandelion < ApplicationRecord
  has_and_belongs_to_many :userinfos
  has_many :file_records, dependent: :destroy
end
