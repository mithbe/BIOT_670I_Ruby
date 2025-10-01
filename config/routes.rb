Rails.application.routes.draw do
  devise_for :users

  resource :account, only: [ :show, :edit, :update ]

  resources :file_records, only: [ :index, :new, :create, :show ] do
    collection do
      post :bulk_prepare   # step 1: upload ZIP and preview file list
      post :bulk_commit    # step 2: confirm metadata, extract and save
    end
  end

  root "home#dashboard"

  get "up" => "rails/health#show", as: :rails_health_check
end