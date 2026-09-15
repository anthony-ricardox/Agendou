class Availability < ApplicationRecord
  belongs_to :provider

  validates :day_of_week, inclusion: { in: 0..6 }
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "deve ser depois do horário de início") if end_time <= start_time
  end
end