Rails.application.routes.draw do
  devise_for :users

  resource :account, only: [:show, :edit, :update]
  resources :samples, only: [:index, :show, :new, :create, :edit, :update, :destroy] # adjust as needed
  resources :file_records, only: [:index, :new, :create, :show]

  root "samples#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
