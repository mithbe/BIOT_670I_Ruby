Rails.application.routes.draw do
  devise_for :users
  resources :samples

  root "samples#index"

  get "up" => "rails/health#show", as: :rails_health_check
end

