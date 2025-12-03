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

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      session[:return_to] = request.fullpath if request.get?
      redirect_to login_path, alert: "Please log in first"
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
