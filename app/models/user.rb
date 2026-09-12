class User < ApplicationRecord
    has_one :provider
    has_many :appointments
    validates :email, presence: true, uniqueness: true
end
