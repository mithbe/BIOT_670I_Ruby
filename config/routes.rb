Rails.application.routes.draw do
  devise_for :users

  # Account management
  resource :account, only: [:show, :edit, :update]

  # File uploads / search
  resources :file_records, only: [:index, :new, :create, :show]

  # Root page (dashboard)
  root "home#dashboard"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
