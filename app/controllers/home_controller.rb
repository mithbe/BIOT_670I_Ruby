class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :dashboard ]

  def dashboard
    # Any data you want to load on the dashboard can go here
  end
end
