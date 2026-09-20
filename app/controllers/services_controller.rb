class ServicesController < ApplicationController
  before_action :require_login
  before_action :require_provider

  def index
    @services = current_user.provider.services
  end

  def new
    @service = current_user.provider.services.build
  end

  def create
    @service = current_user.provider.services.build(service_params)

    if @service.save
      redirect_to services_path, notice: "Serviço criado com sucesso"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def service_params
    params.require(:service).permit(:name, :duration_minutes, :price)
  end

  def require_provider
    unless current_user.provider.present?
      redirect_to new_provider_path, alert: "Você precisa se cadastrar como prestador primeiro"
    end
  end
end