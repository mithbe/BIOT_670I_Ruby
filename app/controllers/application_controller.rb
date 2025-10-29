class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting modern features
  allow_browser versions: :modern

  # Require authentication on all controllers by default
  before_action :authenticate_user!

  # Ensure Devise permits additional params safely
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Redirect users after login
  def after_sign_in_path_for(resource)
    root_path # goes to home#dashboard
  end

  protected

  # Prevent users from modifying email on account update
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email]) # normal signup

    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params[:email] = current_user.email  # force email to remain unchanged
      user_params.permit(:password, :password_confirmation, :current_password)
    end
  end
end