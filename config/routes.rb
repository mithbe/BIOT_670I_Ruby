Rails.application.routes.draw do
  devise_for :users

  resource :account, only: [:show, :edit, :update]
  resources :samples
  resources :file_records, only: [:index, :new, :create, :show]
  resource :account, only: [:show, :edit, :update]
  resources :file_records, only: [:index, :new, :create]
  resources :samples, only: [:index, :show]
  root "samples#index"

  get "up" => "rails/health#show", as: :rails_health_check
end

