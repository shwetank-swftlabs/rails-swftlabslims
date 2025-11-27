module Inventory
  class BaseController < ApplicationController
    before_action :set_inventory_breadcrumbs_root

    private
    def set_inventory_breadcrumbs_root
      add_breadcrumb "Inventory", inventory_path
    end
  end

  class EquipmentsController < BaseController
    before_action :set_equipments_breadcrumbs_root

    def index
    end

    def new
      add_breadcrumb "New", new_inventory_equipment_path
      @equipment = ::Equipment.new
    end

    def create
    end

    private
    def set_equipments_breadcrumbs_root
      add_breadcrumb "Equipments", inventory_equipments_path
    end
  end
end