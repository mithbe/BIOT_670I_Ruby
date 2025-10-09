Rails.application.routes.draw do
  devise_for :users

  resource :account, only: [ :show, :edit, :update ]

  resources :file_records, only: [ :index, :new, :create, :show ] do
    collection do
      post :bulk_prepare
      get  :bulk_preview
      post :bulk_commit
    end
  end

  root "home#dashboard"

  get "up" => "rails/health#show", as: :rails_health_check
end