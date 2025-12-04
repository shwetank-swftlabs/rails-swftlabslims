class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :reset_session, only: [:create, :destroy, :new]

  def new
  end

  def create
    auth  = request.env["omniauth.auth"]
    email = auth.info.email
  
    Rails.logger.info "AUTH: OAuth login attempt for #{email}"
  
    # Try to find existing user
    user = User.find_by(email: email)
  
    if user
      Rails.logger.info "AUTH: Existing user found: #{email}"
    else
      Rails.logger.info "AUTH: No user found, creating new user for #{email}"
      user = User.new(email: email)
  
      unless user.save
        Rails.logger.error "AUTH: Failed to create user #{email}: #{user.errors.full_messages.join(", ")}"
        redirect_to login_path, alert: "Unable to create your user account."
        return
      end
    end
  
    # Login
    session[:user_id] = user.id
    Rails.logger.info "AUTH: User #{email} logged in with session[:user_id] = #{session[:user_id]}"
  
    redirect_to session.delete(:return_to) || root_path
  end

  def destroy
    redirect_to login_path
  end
end