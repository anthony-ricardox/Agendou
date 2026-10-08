class User < ApplicationRecord
  has_secure_password

  has_one :provider
  has_many :appointments

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, allow_nil: true
end