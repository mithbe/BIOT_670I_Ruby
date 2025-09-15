class FileRecord < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :storage_path, presence: true
end

