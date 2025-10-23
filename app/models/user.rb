class User < ApplicationRecord
  has_many :dandelions, dependent: :destroy
  has_many :file_records   # (you likely already have this)
  has_many :upload_batches, dependent: :destroy   # <-- ADD THIS
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
