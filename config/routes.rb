Rails.application.routes.draw do
  resources :samples

  get "up" => "rails/health#show", as: :rails_health_check
end
