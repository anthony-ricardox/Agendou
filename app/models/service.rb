class Service < ApplicationRecord
  belongs_to :provider
  has_many :appointments, dependent: :destroy
  validates :name, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
