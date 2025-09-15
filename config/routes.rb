Rails.application.routes.draw do
  devise_for :users

  # Account management
  resource :account, only: [:show, :edit, :update]

  # Samples management
  resources :samples, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  # File uploads / search
  resources :file_records, only: [:index, :new, :create, :show]

  # Root page (dashboard)
  root "home#dashboard"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
