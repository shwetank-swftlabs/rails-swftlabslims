class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :reset_session, only: [:destroy, :new]

  def new
  end

  def create
    return_to = session[:return_to] || root_path
    auth  = request.env["omniauth.auth"]
    email = auth.info.email
  
    # Try to find existing user
    user = User.find_by(email: email)

    if user.nil?
      user = User.new(email: email)

      unless user.save
        redirect_to login_path, alert: "Unable to create your user account."
        return
      end
    end
  
    # Login
    reset_session
    session[:user_id] = user.id
    redirect_to return_to, notice: "Welcome #{user.first_name.humanize}! You are now logged in.", status: :see_other
  end

  def destroy
    redirect_to login_path
  end
end