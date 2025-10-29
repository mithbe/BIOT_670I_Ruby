class User < ApplicationRecord
  # A user can have many dandelions; deleting a user removes their dandelions too
  has_many :dandelions, dependent: :destroy

  # A user can have many file records
  has_many :file_records

  # A user can have many upload batches; deleting a user removes their batches
  has_many :upload_batches, dependent: :destroy

  # Devise handles authentication. These modules manage:
  # database login, registration, password recovery, remembering sessions, and email validation
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
