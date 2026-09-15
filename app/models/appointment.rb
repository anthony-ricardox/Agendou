class Appointment < ApplicationRecord
  belongs_to :service
  belongs_to :user

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, default: :pending

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_after_starts
  validate :no_overlapping_appointment

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "deve ser depois do horário de início") if ends_at <= starts_at
  end

  def no_overlapping_appointment
    return if starts_at.blank? || ends_at.blank? || service.blank?

    provider = service.provider
    overlapping = Appointment
      .joins(:service)
      .where(services: { provider_id: provider.id })
      .where.not(status: :cancelled)
      .where.not(id: id)
      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)

    errors.add(:base, "Esse horário conflita com outro agendamento") if overlapping.exists?
  end
end