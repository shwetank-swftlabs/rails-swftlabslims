class ApplicationController < ActionController::Base
  INACTIVITY_TIMEOUT = 30.minutes
  allow_browser versions: :modern
  stale_when_importmap_changes

  include Pagy::Method

  helper_method :current_user, :logged_in?

  # Require login for all actions except OmniAuth callbacks & request phase
  before_action :require_login, :init_breadcrumbs, :check_session_timeout

  # OmniAuth MUST bypass login & CSRF verification
  skip_before_action :require_login, if: -> {
    request.path.start_with?("/auth/")
  }

  def index
  end

  def find_polymorphic_parent
    params.each do |key, value|
      next unless key.to_s =~ /(.+)_id$/
      basename = $1.classify
      klass = [basename, "Inventory::#{basename}", "Experiments::#{basename}"].map(&:safe_constantize).compact.first
      return klass.find(value) if klass
    end
    raise "Polymorphic parent not found"
  end

  def redirect_to_polymorphic_parent(resource, tab: nil, flash_hash: {})
    url_params = {}
    url_params = { tab: tab } if tab.present?

    redirect_to polymorphic_url(resource, url_params), flash: flash_hash
  end

  private

  def current_user
    if session[:user_id].present?
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      session[:return_to] = request.fullpath if request.get?
      redirect_to login_path, alert: "Please log in first."
    end
  end

  def require_admin
    unless current_user&.is_admin?
      redirect_to root_path, alert: "You are not authorized to access the admin page."
    end
  end

  def init_breadcrumbs
    @breadcrumbs = [{ name: "Home", path: root_path }]
  end

  def add_breadcrumb(name, path = nil)
    @breadcrumbs << { name: name, path: path }
  end

  def check_session_timeout
    last_seen = session[:last_seen]
  
    # First request OR never set → initialize and continue
    unless last_seen
      session[:last_seen] = Time.current
      return
    end
  
    # Timeout?
    if Time.current - last_seen.to_time > INACTIVITY_TIMEOUT
      reset_session
      redirect_to login_path, alert: "Session timed out. Please log in again." and return
    end
  
    # Otherwise update activity timestamp
    session[:last_seen] = Time.current
  end
end
