class AdminController < ApplicationController
  before_action :require_admin

  def index
    add_breadcrumb "Admin", admin_path
  end
end

