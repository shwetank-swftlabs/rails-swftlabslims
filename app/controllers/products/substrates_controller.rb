module Products
  class SubstratesController < BaseProductsController
    before_action :set_substrates_breadcrumbs_root
    before_action :set_substrate, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Products::Substrate.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Search by CNF name
      if params[:cnf_name].present?
        scope = scope.left_joins(:cnf)
                     .where("products_cnfs.name ILIKE ?", "%#{params[:cnf_name]}%")
      end

      # Filter by substrate type
      if params[:substrate_type].present?
        scope = scope.where(substrate_type: params[:substrate_type])
      end

      @pagy, @substrates = pagy(scope.order(created_at: :desc))
    end

    def new
      add_breadcrumb "Add New Substrate", new_products_substrate_path
      @substrate = Products::Substrate.new
      @substrate.cnf_id = params[:cnf_id] if params[:cnf_id].present?
    end

    def show
      add_breadcrumb "Substrate #{@substrate.name} Details", products_substrate_path(@substrate)
      
      # Paginate usages if on use_records tab
      if params[:tab] == 'use_records'
        @pagy, @usages = pagy(@substrate.usages.order(created_at: :desc))
      end
      
      # Paginate library samples if on library_samples tab
      if params[:tab] == 'library_samples'
        @pagy, @library_samples = pagy(@substrate.library_samples.order(created_at: :desc))
      end

      # Paginate QNC checks if on qnc_check_requests tab
      if params[:tab] == 'qnc_check_requests'
        @pagy, @qnc_check_requests = pagy(@substrate.qnc_check_requests.order(created_at: :desc))
      end
    end

    def create
      @substrate = Products::Substrate.new(substrate_params.except(:created_at))
      @substrate.created_by = current_user.email
      
      # Convert date to datetime if created_at is provided
      if substrate_params[:created_at].present?
        @substrate.created_at = Date.parse(substrate_params[:created_at]).beginning_of_day
      end

      if @substrate.save
        redirect_to products_substrates_path, notice: "Substrate created successfully"
      else
        add_breadcrumb "Add New Substrate", new_products_substrate_path
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit Substrate #{@substrate.name}", edit_products_substrate_path(@substrate)
    end

    def update
      if @substrate.update(update_substrate_params)
        redirect_to products_substrate_path(@substrate), notice: "Substrate updated successfully"
      else
        add_breadcrumb "Edit Substrate #{@substrate.name}", edit_products_substrate_path(@substrate)
        render :edit, status: :unprocessable_entity
      end
    end

    def qr_code
      pdf = @substrate.qr_label_pdf(url: products_substrate_url(@substrate))

      send_data pdf,
        filename: "#{@substrate.name}_qr_code.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    private

    def set_substrates_breadcrumbs_root
      add_breadcrumb "Substrates", products_substrates_path
    end

    def set_substrate
      @substrate = Products::Substrate.find(params[:id])
    end

    def substrate_params
      params.require(:products_substrate).permit(:name, :substrate_type, :quantity, :unit, :tray_description, :location, :cnf_id, :created_at)
    end

    def update_substrate_params
      params.require(:products_substrate).permit(:name, :substrate_type, :quantity, :unit, :tray_description, :location, :cnf_id, :is_active)
    end
  end
end

