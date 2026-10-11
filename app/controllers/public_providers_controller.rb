class PublicProvidersController < ApplicationController
  def index
    @providers = Provider.includes(:user)
  end

  def show
    @provider = Provider.includes(:user).find(params[:id])
    @services = @provider.services.order(:name)
  end
end