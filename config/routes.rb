Rails.application.routes.draw do
  namespace :admin do
    resources :metadatum, only: [ :index, :show, :edit, :update ]
  end

  devise_for :users

  resource :account, only: [ :show, :edit, :update ]

  # File uploads / search
  resources :file_records, only: [ :index, :new, :create, :show ] do
    collection do
      post :bulk_prepare
      get  :bulk_preview
      post :bulk_commit
      get  :search
    end
  end

  root "home#dashboard"

  get "up" => "rails/health#show", as: :rails_health_check
end
