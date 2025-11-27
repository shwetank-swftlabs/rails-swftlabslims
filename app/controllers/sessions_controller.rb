class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :reset_session, only: [:create, :destroy, :new]

  def new
  end

  def create
    auth = request.env["omniauth.auth"]
    
    user = User.find_or_create_by(email: auth.info.email)
    user.name = auth.info.name
  
    if user.save!
      session[:user_id] = user.id
      redirect_to session[:return_to] || experiments_path, notice: "Welcome, #{user.first_name}! You are now logged in."
    else
      redirect_to login_path, alert: "Failed to log in. Please try again or contact support."
    end
  end

  def destroy
    redirect_to root_path, notice: "Logged out successfully"
  end
end