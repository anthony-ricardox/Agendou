class AppointmentsController < ApplicationController
  before_action :require_login
  before_action :set_appointment, only: [:destroy]
  before_action :require_provider, only: [:schedule]

  def index
    @appointments = current_user.appointments.order(starts_at: :asc)
  end

  def schedule
    @appointments = current_user.provider.appointments.order(starts_at: :asc)
  end

  def new
    @service = Service.find(params[:service_id])
    @available_slots = calculate_available_slots(@service)
  end

  def create
    @service = Service.find(params[:service_id])
    starts_at = Time.zone.parse(params[:starts_at])
    ends_at = starts_at + @service.duration_minutes.minutes

    @appointment = Appointment.new(
      service: @service,
      user: current_user,
      starts_at: starts_at,
      ends_at: ends_at
    )

    if @appointment.save
      redirect_to appointments_path, notice: "Agendamento confirmado!"
    else
      @available_slots = calculate_available_slots(@service)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @appointment.cancelled!
    redirect_to appointments_path, notice: "Agendamento cancelado"
  end

  private

  def set_appointment
    @appointment = current_user.appointments.find(params[:id])
  end

  def require_provider
    unless current_user.provider.present?
      redirect_to root_path, alert: "Você precisa ser um prestador"
    end
  end

  def calculate_available_slots(service)
    provider = service.provider
    slots = []

    (0..6).each do |day_offset|
      date = Date.current + day_offset.days
      availability = provider.availabilities.find_by(day_of_week: date.wday)
      next unless availability

      slot_start = date.to_time.change(hour: availability.start_time.hour, min: availability.start_time.min)
      day_end = date.to_time.change(hour: availability.end_time.hour, min: availability.end_time.min)

      while slot_start + service.duration_minutes.minutes <= day_end
        slot_end = slot_start + service.duration_minutes.minutes

        conflict = Appointment
          .joins(:service)
          .where(services: { provider_id: provider.id })
          .where.not(status: :cancelled)
          .where("starts_at < ? AND ends_at > ?", slot_end, slot_start)
          .exists?

        slots << slot_start unless conflict

        slot_start = slot_end
      end
    end

    slots
  end
end