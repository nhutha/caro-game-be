class User < ApplicationRecord
  has_secure_password

  has_many :refresh_tokens, dependent: :destroy
  has_many :room_as_masters, class_name: "Room", foreign_key: "master_id", dependent: :destroy
  has_many :room_as_guests, class_name: "Room", foreign_key: "guest_id", dependent: :nullify

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
