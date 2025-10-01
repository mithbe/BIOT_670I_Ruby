class UploadBatch < ApplicationRecord
  belongs_to :user
  has_one_attached :archive  # Active Storage attachment
  STATUSES = %w[uploaded prepared committed expired].freeze

  validates :status, inclusion: { in: STATUSES }

  def prepared!
    update!(status: "prepared")
  end

  def committed!
    update!(status: "committed")
  end
end