Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resource :session, only: [:new, :create, :destroy]
  resource :provider, only: [:new, :create, :edit, :update]
  resources :services
  resources :availabilities

  resources :providers, only: [:index, :show], controller: "public_providers"
  resources :appointments, only: [:index, :new, :create, :destroy]

  get "pages/home"
  root "pages#home"
end