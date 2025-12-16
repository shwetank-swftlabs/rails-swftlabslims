module Products
  class CakesController < BaseProductsController
    before_action :set_cakes_breadcrumbs_root
    before_action :set_cake, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Products::Cake.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Search by batch_number
      if params[:batch_number].present?
        scope = scope.left_joins(:nop_process)
                     .where("nop_processes.batch_number ILIKE ?", "%#{params[:batch_number]}%")
      end

      @pagy, @cakes = pagy(scope.order(:name))
    end

    def new
      add_breadcrumb "Add New Cake", new_products_cake_path
      @cake = Products::Cake.new
    end

    def show
      add_breadcrumb "Cake #{@cake.name} Details", products_cake_path(@cake)
      
      # Paginate usages if on use_records tab
      if params[:tab] == 'use_records'
        @pagy, @usages = pagy(@cake.usages.order(created_at: :desc))
      end
      
      # Paginate library samples if on library_samples tab
      if params[:tab] == 'library_samples'
        @pagy, @library_samples = pagy(@cake.library_samples.order(created_at: :desc))
      end

      # Paginate QNC checks if on qnc_checks tab
      if params[:tab] == 'qnc_checks'
        @pagy, @qnc_checks = pagy(@cake.qnc_checks.order(created_at: :desc))
      end

      # Paginate CNFs if on cnfs tab
      if params[:tab] == 'cnfs'
        @pagy, @cnfs = pagy(@cake.cnfs.order(created_at: :desc))
      end
    end

    def create
      @cake = Products::Cake.new(cake_params)
      @cake.created_by = current_user.email

      if @cake.save
        redirect_to products_cakes_path, notice: "Cake created successfully"
      else
        add_breadcrumb "Add New Cake", new_products_cake_path
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit Cake #{@cake.name}", edit_products_cake_path(@cake)
    end

    def update
      if @cake.update(update_cake_params)
        redirect_to products_cake_path(@cake), notice: "Cake updated successfully"
      else
        add_breadcrumb "Edit Cake #{@cake.name}", edit_products_cake_path(@cake)
        render :edit, status: :unprocessable_entity
      end
    end

    def qr_code
      pdf = @cake.qr_label_pdf(url: products_cake_url(@cake))

      send_data pdf,
        filename: "#{@cake.name}_qr_code.pdf",
        type: "application/pdf",
        disposition: "inline"
    end

    def redirect_to_index
      redirect_to products_cakes_path, alert: "The old QRs are no longer valid. Please print a new QR."
    end

    private

    def set_cakes_breadcrumbs_root
      add_breadcrumb "Cakes", products_cakes_path
    end

    def set_cake
      @cake = Products::Cake.find(params[:id])
    end

    def cake_params
      params.require(:products_cake).permit(:name, :quantity, :unit, :moisture_percentage, :ph, :batch_number)
    end

    def update_cake_params
      params.require(:products_cake).permit(:name, :quantity, :unit, :moisture_percentage, :ph)
    end
  end
end