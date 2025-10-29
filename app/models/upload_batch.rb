class UploadBatch < ApplicationRecord
  # Each batch belongs to a user
  belongs_to :user

  # Optional archive file stored via Active Storage
  has_one_attached :archive

  # 'files' column stores an array of file info as JSON
  # Example: { "path": "dir/file.png", "size": 1234, "ext": ".png", "type": "image" }

  # Make sure every batch has a status
  validates :status, presence: true

  # Convenience methods to check batch state
  def prepared?
    status == "prepared"
  end

  def committed?
    status == "committed"
  end
end
