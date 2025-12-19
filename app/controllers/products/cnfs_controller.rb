module Products
  class CnfsController < BaseProductsController
    before_action :set_cnfs_breadcrumbs_root
    before_action :set_cnf, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Products::Cnf.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Search by cake name
      if params[:cake_name].present?
        scope = scope.left_joins(:cake)
                     .where("products_cakes.name ILIKE ?", "%#{params[:cake_name]}%")
      end

      @pagy, @cnfs = pagy(scope.order(created_at: :desc))
    end

    def new
      add_breadcrumb "Add New CNF", new_products_cnf_path
      @cnf = Products::Cnf.new
      @cnf.cake_id = params[:cake_id] if params[:cake_id].present?
    end

    def show
      add_breadcrumb "CNF #{@cnf.name} Details", products_cnf_path(@cnf)
      
      # Paginate usages if on use_records tab
      if params[:tab] == 'use_records'
        @pagy, @usages = pagy(@cnf.usages.order(created_at: :desc))
      end
      
      # Paginate library samples if on library_samples tab
      if params[:tab] == 'library_samples'
        @pagy, @library_samples = pagy(@cnf.library_samples.order(created_at: :desc))
      end

      # Paginate QNC checks if on qnc_check_requests tab
      if params[:tab] == 'qnc_check_requests'
        @pagy, @qnc_checks = pagy(@cnf.qnc_check_requests.order(created_at: :desc))
      end
    end

    def create
      @cnf = Products::Cnf.new(cnf_params.except(:created_at))
      @cnf.created_by = current_user.email
      
      # Convert date to datetime if created_at is provided
      if cnf_params[:created_at].present?
        @cnf.created_at = Date.parse(cnf_params[:created_at]).beginning_of_day
      end

      if @cnf.save
        redirect_to products_cnfs_path, notice: "CNF created successfully"
      else
        add_breadcrumb "Add New CNF", new_products_cnf_path
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit CNF #{@cnf.name}", edit_products_cnf_path(@cnf)
    end

    def update
      if @cnf.update(update_cnf_params)
        redirect_to products_cnf_path(@cnf), notice: "CNF updated successfully"
      else
        add_breadcrumb "Edit CNF #{@cnf.name}", edit_products_cnf_path(@cnf)
        render :edit, status: :unprocessable_entity
      end
    end

    def qr_code
      pdf = @cnf.qr_label_pdf(url: products_cnf_url(@cnf))

      send_data pdf,
        filename: "#{@cnf.name}_qr_code.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    private

    def set_cnfs_breadcrumbs_root
      add_breadcrumb "CNFs", products_cnfs_path
    end

    def set_cnf
      @cnf = Products::Cnf.find(params[:id])
    end

    def cnf_params
      params.require(:products_cnf).permit(:name, :quantity, :unit, :location, :cake_id, :created_at)
    end

    def update_cnf_params
      params.require(:products_cnf).permit(:name, :quantity, :unit, :location, :cake_id, :is_active)
    end
  end
end

