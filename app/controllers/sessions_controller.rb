class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :reset_session, only: [:destroy]

  def new
    # Preserve return_to when showing login page
    @return_to = session[:return_to]
  end

  def create
    # Save return_to before resetting session
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
  
    # Login - reset session but preserve return_to
    reset_session
    session[:user_id] = user.id
    
    # Count pending QNC checks assigned to this user
    pending_qnc_checks_count = Experiments::QncCheck.where(
      requested_from: user.email,
      is_active: true
    ).count
    
    # Build welcome message
    welcome_message = "Welcome #{user.first_name.humanize}! You are now logged in."
    if pending_qnc_checks_count > 0
      welcome_message += " You have #{pending_qnc_checks_count} QNC check#{pending_qnc_checks_count == 1 ? '' : 's'} pending."
    end
    
    redirect_to return_to, notice: welcome_message, status: :see_other
  end

  def destroy
    redirect_to login_path
  end
end