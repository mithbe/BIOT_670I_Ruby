class FileRecord < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :storage_path, presence: true
  # Can Delete Below if doesn't work
  belongs_to :dandelion, optional: true
  belongs_to :userinfo, optional: true
  # Made this when making metadatum table
  has_many :metadatum, dependent: :destroy
end
