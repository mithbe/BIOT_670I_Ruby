class FileUpload < ApplicationRecord
  # Each uploaded file is associated with a user
  belongs_to :user

  # Each uploaded file is linked to a dandelion record
  belongs_to :dandelion
end
