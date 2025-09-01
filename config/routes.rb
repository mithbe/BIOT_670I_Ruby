Rails.application.routes.draw do
  resources :samples
  root "samples#index"
end