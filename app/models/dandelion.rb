class Dandelion < ApplicationRecord
  # Each dandelion record belongs to a user
  belongs_to :user
end
