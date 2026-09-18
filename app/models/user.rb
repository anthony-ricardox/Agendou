class User < ApplicationRecord
    has_secure_password
    has_one :provider
    has_many :appointments
    validates :email, presence: true, uniqueness: true
end
