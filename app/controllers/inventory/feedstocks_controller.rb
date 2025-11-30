module Inventory
  class FeedstocksController < BaseController
    before_action :set_feedstocks_breadcrumbs_root
    before_action :set_feedstock, only: [:show, :qr_code]

    def index
      scope = Inventory::Feedstock.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    
      # Filter by type
      scope = scope.where(feedstock_type: params[:feedstock_type]) if params[:feedstock_type].present?
    
      @pagy, @feedstocks = pagy(scope.order(:name), items: 15)
    end

    def new
      add_breadcrumb "Add New Feedstock", new_inventory_feedstock_path
      @feedstock = Inventory::Feedstock.new
    end

    def show
      add_breadcrumb "#{@feedstock.feedstock_type.titleize} #{@feedstock.name} Details", inventory_feedstock_path(@feedstock)
    end 

    def create
      @feedstock = Inventory::Feedstock.new(feedstock_params)
      if @feedstock.save
        redirect_to inventory_feedstocks_path, notice: "Feedstock created successfully"
      else
        add_breadcrumb "Add New Feedstock", new_inventory_feedstock_path
        render :new, status: :unprocessable_entity
      end
    end

    def qr_code
      pdf = @feedstock.qr_label_pdf(url: inventory_feedstock_url(@feedstock))

      send_data pdf,
        filename: "#{@feedstock.name}_qr_code.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    private
    def set_feedstocks_breadcrumbs_root
      add_breadcrumb "Feedstocks", inventory_feedstocks_path
    end

    def set_feedstock
      @feedstock = Inventory::Feedstock.find(params[:id])
    end

    def feedstock_params
      params.require(:inventory_feedstock).permit(:name, :feedstock_type, :quantity, :unit, :supplier, :location, :created_by, :created_at)
    end
  end
end

