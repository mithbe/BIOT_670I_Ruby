class AccountsController < ApplicationController
  def show
  end

  def edit
  end

  def update
    if current_user.update(account_params)
      redirect_to account_path, notice: "Account updated successfully."
    else
      flash.now[:alert] = "Failed to update account."
      render :edit
    end
  end

  private

  def account_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end