
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
      scope = ::Equipment.all
    
      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    
      # Filter by type
      scope = scope.where(equipment_type: params[:equipment_type]) if params[:equipment_type].present?
    
      @pagy, @equipments = pagy(scope.order(:name), items: 15)
    end

    def new
      add_breadcrumb "Add New Equipment", new_inventory_equipment_path
      @equipment = ::Equipment.new
    end

    def show
      @equipment = ::Equipment.find(params[:id])
    end

    def create
      @equipment = ::Equipment.new(equipment_params)
      @equipment.code.upcase!

      if @equipment.save
        redirect_to inventory_equipments_path, notice: "Equipment created successfully"
      else
        flash.now[:alert] = "Failed to create equipment. Please check the form and try again."
        render :new, status: :unprocessable_entity
      end
    end

    private
    def set_equipments_breadcrumbs_root
      add_breadcrumb "Equipments", inventory_equipments_path
    end

    def equipment_params
      params.require(:equipment).permit(:name, :code, :equipment_type, :equipment_supplier, :equipment_location, :location_details, :created_by, :created_at)
    end
  end
end