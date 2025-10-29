class HomeController < ApplicationController
  # Skip authentication for the dashboard page so anyone can access it
  skip_before_action :authenticate_user!, only: [ :dashboard ]

  # Display the dashboard page
  # You can load any data needed for the dashboard here
  def dashboard
  end
end
