module Inventory
  class ChemicalsController < BaseController
    before_action :set_chemicals_breadcrumbs_root
    before_action :set_chemical, only: [:show, :qr_code, :edit, :update]

    def index
      scope = Inventory::Chemical.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    
      # Filter by type
      scope = scope.where(chemical_type_id: params[:chemical_type_id]) if params[:chemical_type_id].present?
    
      # Filter by is_active
      if params[:is_active].present?
        is_active_value = params[:is_active] == "true"
        scope = scope.where(is_active: is_active_value)
      end
    
      @pagy, @chemicals = pagy(scope.order(:name), items: 15)
    end

    def new
      add_breadcrumb "Add New Chemical", new_inventory_chemical_path
      @chemical = Inventory::Chemical.new
    end

    def show
      add_breadcrumb "#{@chemical.chemical_type.name.humanize} #{@chemical.name} Details", inventory_chemical_path(@chemical)
    end 

    def create
      @chemical = Inventory::Chemical.new(chemical_params)
      @chemical.created_by = current_user.email
      
      if @chemical.save
        redirect_to inventory_chemicals_path, notice: "Chemical created successfully"
      else
        render :new
      end
    end

    def qr_code
      pdf = @chemical.qr_label_pdf(url: inventory_chemical_url(@chemical))

      send_data pdf,
        filename: "#{@chemical.name}_qr_code.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    def edit
      add_breadcrumb "Edit Chemical #{@chemical.name}", edit_inventory_chemical_path(@chemical)
    end

    def update
      if @chemical.update(update_chemical_params)
        redirect_to inventory_chemical_path(@chemical), notice: "Chemical updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_chemicals_breadcrumbs_root
      add_breadcrumb "Chemicals", inventory_chemicals_path
    end

    def set_chemical
      @chemical = Inventory::Chemical.find(params[:id])
    end

    def chemical_params
      params.require(:inventory_chemical).permit(:name, :chemical_type_id, :quantity, :unit, :supplier, :location, :expiry_date)
    end

    def update_chemical_params
      params.require(:inventory_chemical).permit(:supplier, :location, :expiry_date, :is_active)
    end
  end
end