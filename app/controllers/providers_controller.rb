class ProvidersController < ApplicationController
  before_action :require_login
  before_action :redirect_if_already_provider, only: [:new, :create]

  def new
    @provider = Provider.new
  end

  def create
    @provider = current_user.build_provider(provider_params)

    if @provider.save
      redirect_to root_path, notice: "Agora você é um prestador de serviços!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @provider = current_user.provider
  end

  def update
    @provider = current_user.provider

    if @provider.update(provider_params)
      redirect_to root_path, notice: "Perfil atualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def provider_params
    params.require(:provider).permit(:bio)
  end

  def redirect_if_already_provider
    redirect_to root_path, alert: "Você já é um prestador" if current_user.provider.present?
  end
end