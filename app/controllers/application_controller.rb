class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  include Pagy::Method

  helper_method :current_user, :logged_in?

  # Require login for all actions except when skipped
  before_action :require_login, :init_breadcrumbs

  private

  # def current_user
  #   @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  # end

  def current_user
    if session[:user_id].present?
      Rails.logger.info "AUTH: session[:user_id] = #{session[:user_id]}"
      @current_user ||= User.find_by(id: session[:user_id])
      Rails.logger.info "AUTH: current_user resolved as #{@current_user&.email || 'nil'}"
    else
      Rails.logger.info "AUTH: No session[:user_id] present"
    end
  
    @current_user
  end


  # def logged_in?
  #   !!current_user
  # end

  def logged_in?
    is_logged_in = !!current_user
    Rails.logger.info "AUTH: logged_in? = #{is_logged_in}"
    is_logged_in
  end


  # def require_login
  #   unless logged_in?
  #     session[:return_to] = request.fullpath if request.get?
  #     redirect_to login_path, alert: "Please log in first"
  #   end
  # end

  def require_login
    Rails.logger.info "AUTH: require_login before_action on #{request.fullpath}"
  
    unless logged_in?
      reason = session[:user_id].present? ? "User record not found" : "No session present"
  
      Rails.logger.warn "AUTH: Not authenticated (#{reason}). Redirecting to login_path."
  
      session[:return_to] = request.fullpath if request.get?
      redirect_to login_path, alert: "Please log in first"
    else
      Rails.logger.info "AUTH: Access granted to #{current_user.email} for #{request.fullpath}"
    end
  end

  def require_admin
    unless current_user.is_admin?
      redirect_to root_path, alert: "You are not authorized to access the admin page."
    end
  end

  private

  def init_breadcrumbs
    @breadcrumbs = []
  end

  def add_breadcrumb(name, path = nil)
    @breadcrumbs << { name: name, path: path }
  end
end
