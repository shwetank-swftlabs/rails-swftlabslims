module Inventory
  class EquipmentsController < BaseController
    before_action :set_equipments_breadcrumbs_root
    before_action :set_equipment, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Inventory::Equipment.all
    
      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    
      # Filter by type
      scope = scope.where(equipment_type_id: params[:equipment_type_id]) if params[:equipment_type_id].present?
    
      # Filter by is_active
      if params[:is_active].present?
        is_active_value = params[:is_active] == "true"
        scope = scope.where(is_active: is_active_value)
      end
    
      @pagy, @equipments = pagy(scope.order(:name), items: 15)
    end

    def new
      add_breadcrumb "Add New Equipment", new_inventory_equipment_path
      @equipment = Inventory::Equipment.new
    end

    def show
      add_breadcrumb @equipment.name, inventory_equipment_path(@equipment)
    end

    def create
      @equipment = Inventory::Equipment.new(equipment_params)
      @equipment.code.upcase!
      @equipment.created_by = current_user.email
      
      if @equipment.save
        redirect_to inventory_equipments_path, notice: "Equipment created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit Equipment", edit_inventory_equipment_path(@equipment)
    end

    def update
      if @equipment.update(update_equipment_params)
        redirect_to inventory_equipment_path(@equipment), notice: "Equipment updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def qr_code
      pdf = @equipment.qr_label_pdf(url: inventory_equipment_url(@equipment))

      send_data pdf,
        filename: "#{@equipment.name}_qr_code.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    private
    def set_equipments_breadcrumbs_root
      add_breadcrumb "Equipments", inventory_equipments_path
    end

    def equipment_params
      params.require(:inventory_equipment).permit(:name, :code, :equipment_type_id)
    end

    def update_equipment_params
      params.require(:inventory_equipment).permit(:name, :code, :equipment_type_id, :supplier, :location, :is_active)
    end

    def set_equipment
      @equipment = Inventory::Equipment.find(params[:id])
    end
  end
end