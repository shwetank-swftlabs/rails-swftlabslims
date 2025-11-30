module Inventory
  class BaseController < ApplicationController
    before_action :set_inventory_breadcrumbs_root

    private
    def set_inventory_breadcrumbs_root
      add_breadcrumb "Inventory", inventory_path
    end
  end
end

