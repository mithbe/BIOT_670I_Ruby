class UploadBatch < ApplicationRecord
  belongs_to :user

  has_one_attached :archive    # relies on Active Storage

  # files is a JSON column; store an array of file descriptors
  # Example element: { "path": "dir/file.png", "size": 1234, "ext": ".png", "type": "image" }

  validates :status, presence: true

  # convenience helpers
  def prepared?
    status == "prepared"
  end

  def committed?
    status == "committed"
  end
end