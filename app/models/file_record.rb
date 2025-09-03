class FileRecord < ApplicationRecord
  validates :name, presence: true
  validates :storage_path, presence: true
end
