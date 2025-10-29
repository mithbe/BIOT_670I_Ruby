Rails.application.routes.draw do
  # Admin namespace for managing metadata
  namespace :admin do
    resources :metadatum, only: [ :index, :show, :edit, :update ]
  end

  # User authentication via Devise
  devise_for :users

  # Account management routes
  resource :account, only: [ :show, :edit, :update ]

  # File uploads and search functionality
  resources :file_records, only: [ :index, :new, :create, :show ] do
    collection do
      post :bulk_prepare   # Prepare multiple files for upload
      get  :bulk_preview   # Preview multiple files before committing
      post :bulk_commit    # Commit the bulk upload
      get  :search         # Search uploaded files
    end
  end

  # Main dashboard
  root "home#dashboard"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check
end
