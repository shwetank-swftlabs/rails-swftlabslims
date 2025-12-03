module Admin
  class EquipmentTypesController < ApplicationController
    before_action :require_admin
    before_action :set_equipment_type, only: [:edit, :update]

    def index
      @equipment_types = Admin::EquipmentType.all.order(:name)
    end

    def new
      @equipment_type = Admin::EquipmentType.new
    end

    def create
      @equipment_type = Admin::EquipmentType.new(equipment_type_params)
      @equipment_type.created_by = current_user.email

      if @equipment_type.save
        redirect_to admin_equipment_types_path, notice: "Equipment type created successfully"
      else
        flash.now[:alert] = "Failed to create equipment type. Please check the form and try again."
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @equipment_type.update(equipment_type_params)
        redirect_to admin_equipment_types_path, notice: "Equipment type updated successfully"
      else
        flash.now[:alert] = "Failed to update equipment type. Please check the form and try again."
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle_active
      @equipment_type.update(is_active: !@equipment_type.is_active)
      redirect_to admin_equipment_types_path, notice: "Equipment type #{@equipment_type.is_active? ? 'activated' : 'deactivated'} successfully"
    end

    private

    def set_equipment_type
      @equipment_type = Admin::EquipmentType.find(params[:id])
    end

    def equipment_type_params
      params.require(:admin_equipment_type).permit(:name, :is_active, :created_by, :created_at)
    end
  end
end