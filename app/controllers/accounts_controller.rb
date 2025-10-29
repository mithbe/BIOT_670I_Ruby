class AccountsController < ApplicationController
  # Require the user to be logged in for all actions
  before_action :authenticate_user!

  # Show the current user's account details
  def show
    @user = current_user
  end

  # Render the form to edit the current user's account
  def edit
    @user = current_user
  end

  # Update the current user's account information
  def update
    @user = current_user
    if @user.update(account_params)
      redirect_to account_path, notice: "Account updated successfully."
    else
      flash.now[:alert] = "Failed to update account."
      render :edit
    end
  end

  private

  # Only allow email and password fields to be updated
  def account_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
