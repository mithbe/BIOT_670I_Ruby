class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting modern features
  allow_browser versions: :modern

  # Require authentication on all controllers by default
  before_action :authenticate_user!

  # Redirect users after login
  def after_sign_in_path_for(resource)
    root_path # goes to home#dashboard
  end
end
