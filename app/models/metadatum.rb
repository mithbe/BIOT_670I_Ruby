class Metadatum < ApplicationRecord
  belongs_to :file_record
  validates :key, presence: true
end
