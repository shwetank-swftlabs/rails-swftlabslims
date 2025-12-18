module Inventory
  class ChemicalsController < BaseController
    before_action :set_chemicals_breadcrumbs_root
    before_action :set_chemical, only: [:show, :qr_code, :edit, :update, :new_derived]

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

      # Filter by original/derived
      if params[:derived].present?
        if params[:derived] == "true"
          scope = scope.where.not(parent_chemical_id: nil)
        elsif params[:derived] == "false"
          scope = scope.where(parent_chemical_id: nil)
        end
      end
    
      @pagy, @chemicals = pagy(scope.order(:name))
    end

    def new
      add_breadcrumb "Add New Chemical", new_inventory_chemical_path
      @chemical = Inventory::Chemical.new
    end

    def new_derived
      add_breadcrumb "#{@chemical.chemical_type.name.humanize} #{@chemical.name} Details", inventory_chemical_path(@chemical)
      add_breadcrumb "Add Derived Chemical", new_derived_inventory_chemical_path(@chemical)
      @derived_chemical = Inventory::Chemical.new(
        parent_chemical_id: @chemical.id,
        chemical_type_id: @chemical.chemical_type_id,
        supplier: @chemical.supplier
      )
    end

    def show
      add_breadcrumb "#{@chemical.chemical_type.name.humanize} #{@chemical.name} Details", inventory_chemical_path(@chemical)
      # Paginate usages if on use_records tab
      if params[:tab] == 'use_records'
        @pagy_usages, @usages = pagy(@chemical.usages.order(updated_at: :desc))
      end
      # Paginate derived chemicals if on derived_chemicals tab
      if params[:tab] == 'derived_chemicals'
        @pagy_derived, @derived_chemicals = pagy(@chemical.derived_chemicals.order(:name))
      end
    end 

    def create
      @chemical = Inventory::Chemical.new(chemical_params)
      @chemical.created_by = current_user.email
      
      if @chemical.save
        redirect_to inventory_chemicals_path, notice: "Chemical created successfully"
      else
        # Determine which view to render based on whether it's a derived chemical
        if @chemical.parent_chemical_id.present?
          @derived_chemical = @chemical
          @chemical = Inventory::Chemical.find(@derived_chemical.parent_chemical_id)
          render :new_derived, status: :unprocessable_entity
        else
          render :new, status: :unprocessable_entity
        end
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
      params.require(:inventory_chemical).permit(:name, :chemical_type_id, :quantity, :unit, :supplier, :location, :expiry_date, :parent_chemical_id)
    end

    def update_chemical_params
      params.require(:inventory_chemical).permit(:supplier, :location, :expiry_date, :is_active)
    end
  end
end