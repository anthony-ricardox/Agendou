Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resource :session, only: [:new, :create, :destroy]
  resource :provider, only: [:new, :create, :edit, :update]
  resources :services, only: [:index, :new, :create]

  get "pages/home"
  root "pages#home"
end