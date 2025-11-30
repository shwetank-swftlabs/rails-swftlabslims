module Inventory
  class ChemicalsController < BaseController
    before_action :set_chemicals_breadcrumbs_root
    before_action :set_chemical, only: [:show, :qr_code]

    def index
      scope = Inventory::Chemical.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    
      # Filter by type
      scope = scope.where(chemical_type: params[:chemical_type]) if params[:chemical_type].present?
    
      @pagy, @chemicals = pagy(scope.order(:name), items: 15)
    end

    def new
      add_breadcrumb "Add New Chemical", new_inventory_chemical_path
      @chemical = Inventory::Chemical.new
    end

    def show
      add_breadcrumb "#{@chemical.chemical_type.titleize} #{@chemical.name} Details", inventory_chemical_path(@chemical)
    end 

    def create
      @chemical = Inventory::Chemical.new(chemical_params)
      if @chemical.save
        redirect_to inventory_chemical_path(@chemical), notice: "Chemical created successfully"
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

    private
    def set_chemicals_breadcrumbs_root
      add_breadcrumb "Chemicals", inventory_chemicals_path
    end

    def set_chemical
      @chemical = Inventory::Chemical.find(params[:id])
    end

    def chemical_params
      params.require(:inventory_chemical).permit(:name, :chemical_type, :quantity, :unit, :supplier, :location, :location_details, :expiry_date, :created_by, :created_at)
    end
  end
end