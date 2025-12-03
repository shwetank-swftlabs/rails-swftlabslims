class Admin::BaseAdminController < ApplicationController
  before_action :require_admin, :set_admin_breadcrumbs_root

  private

  def set_admin_breadcrumbs_root
    add_breadcrumb "Admin", admin_path
  end
end