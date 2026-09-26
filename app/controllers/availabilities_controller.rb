class AvailabilitiesController < ApplicationController
  before_action :require_login
  before_action :require_provider
  before_action :set_availability, only: [:edit, :update, :destroy]

  def index
    @availabilities = current_user.provider.availabilities
  end

  def new
    @availability = current_user.provider.availabilities.build
  end

  def create
    @availability = current_user.provider.availabilities.build(availability_params)

    if @availability.save
      redirect_to availabilities_path, notice: "Disponibilidade criada com sucesso"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @availability.update(availability_params)
      redirect_to availabilities_path, notice: "Disponibilidade atualizada"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @availability.destroy
    redirect_to availabilities_path, notice: "Disponibilidade removida"
  end

  private

  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time)
  end

  def require_provider
    unless current_user.provider.present?
      redirect_to new_provider_path, alert: "Você precisa se cadastrar como prestador primeiro"
    end
  end

  def set_availability
    @availability = current_user.provider.availabilities.find(params[:id])
  end
end