class PublicProvidersController < ApplicationController
  def index
    @providers = Provider.all
  end

  def show
    @provider = Provider.find(params[:id])
    @services = @provider.services
  end
end