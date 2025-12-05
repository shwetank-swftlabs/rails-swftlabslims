module Inventory
  class FeedstocksController < BaseController
    before_action :set_feedstocks_breadcrumbs_root
    before_action :set_feedstock, only: [:show, :qr_code, :edit, :update]

    def index
      scope = Inventory::Feedstock.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    
      # Filter by type
      scope = scope.where(feedstock_type_id: params[:feedstock_type_id]) if params[:feedstock_type_id].present?
    
      # Filter by is_active
      if params[:is_active].present?
        is_active_value = params[:is_active] == "true"
        scope = scope.where(is_active: is_active_value)
      end
    
      @pagy, @feedstocks = pagy(scope.order(:name), items: 15)
    end

    def new
      add_breadcrumb "Add New Feedstock", new_inventory_feedstock_path
      @feedstock = Inventory::Feedstock.new
    end

    def show
      add_breadcrumb "#{@feedstock.feedstock_type.name.humanize} #{@feedstock.name} Details", inventory_feedstock_path(@feedstock)
      
      # Paginate usages if on use_records tab
      if params[:tab].to_s == 'use_records'
        @pagy, @usages = pagy(@feedstock.usages.order(updated_at: :desc), items: 15)
      else
        @usages = []
        @pagy = nil
      end
    end 

    def create
      @feedstock = Inventory::Feedstock.new(create_feedstock_params)
      @feedstock.created_by = current_user.email

      if @feedstock.save
        redirect_to inventory_feedstocks_path, notice: "Feedstock created successfully"
      else
        add_breadcrumb "Add New Feedstock", new_inventory_feedstock_path
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit Feedstock #{@feedstock.name}", edit_inventory_feedstock_path(@feedstock)
    end

    def update
      if @feedstock.update(update_feedstock_params)
        redirect_to inventory_feedstock_path(@feedstock), notice: "Feedstock updated successfully"
      else
        add_breadcrumb "Edit Feedstock #{@feedstock.name}", edit_inventory_feedstock_path(@feedstock)
        render :edit, status: :unprocessable_entity
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

    def create_feedstock_params
      params.require(:inventory_feedstock).permit(:feedstock_type_id, :name, :quantity, :unit, :supplier, :location)
    end

    def update_feedstock_params
      params.require(:inventory_feedstock).permit(:name, :supplier, :location, :is_active)
    end
  end
end

