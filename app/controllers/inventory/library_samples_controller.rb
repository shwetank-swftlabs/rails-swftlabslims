module Inventory
  class LibrarySamplesController < BaseController
    before_action :set_library_samples_breadcrumbs_root, only: [:index, :new, :show, :edit]
    before_action :set_library_sample, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Inventory::LibrarySample.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Filter by is_active
      if params[:is_active].present?
        is_active_value = params[:is_active] == "true"
        scope = scope.where(is_active: is_active_value)
      end

      @pagy, @library_samples = pagy(scope.order(created_at: :desc))
    end

    def new
      @library_sampleable = load_library_sampleable
      @parent = @library_sampleable # For view compatibility
      @library_sample = build_library_sample

      if @library_sampleable
        add_breadcrumb parent_breadcrumb_name(@library_sampleable),
                       polymorphic_path(@library_sampleable)
      end

      add_breadcrumb "Add Library Sample"
    end

    def show
      add_breadcrumb "Library Sample #{@library_sample.name} Details",
                     inventory_library_sample_path(@library_sample)
    end

    def create
      @library_sampleable = load_library_sampleable
      @library_sample = build_library_sample_from_create
      @library_sample.assign_attributes(library_sample_params)
      @library_sample.created_by = current_user.email
    
      if @library_sample.save
        redirect_to redirect_path_for(@library_sampleable),
                    notice: "Library sample created successfully",
                    status: :see_other
      else
        @parent = @library_sampleable # For view compatibility
        if @library_sampleable
          add_breadcrumb parent_breadcrumb_name(@library_sampleable),
                         polymorphic_path(@library_sampleable)
        end
    
        add_breadcrumb "Add Library Sample"
        render :new, status: :unprocessable_entity
      end
    end
    

    def edit
      add_breadcrumb "Edit Library Sample #{@library_sample.name}",
                     edit_inventory_library_sample_path(@library_sample)
    end

    def update
      if @library_sample.update(update_library_sample_params)
        redirect_to inventory_library_sample_path(@library_sample),
                    notice: "Library sample updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def qr_code
      pdf = @library_sample.qr_label_pdf(
        url: inventory_library_sample_url(@library_sample)
      )

      send_data pdf,
                filename: "#{@library_sample.name}_qr_code.pdf",
                type: "application/pdf",
                disposition: "inline"
    end

    private

    def set_library_samples_breadcrumbs_root
      add_breadcrumb "Library Samples", inventory_library_samples_path
    end

    def set_library_sample
      @library_sample = Inventory::LibrarySample.find(params[:id])
    end

    def load_library_sampleable
      return unless params[:parent_type].present? && params[:parent_id].present?

      params[:parent_type].constantize.find(params[:parent_id])
    rescue NameError, ActiveRecord::RecordNotFound
      nil
    end

    def build_library_sample
      if @library_sampleable
        library_sample = @library_sampleable.library_samples.build
        library_sample.unit = @library_sampleable.unit
        library_sample
      else
        Inventory::LibrarySample.new
      end
    end

    def build_library_sample_from_create
      if @library_sampleable
        @library_sampleable.library_samples.new
      else
        Inventory::LibrarySample.new
      end
    end
    
    def redirect_path_for(parent)
      if parent
        polymorphic_path(parent, tab: :library_samples)
      else
        inventory_library_samples_path
      end
    end


    def find_parent_from_params(parent_type, parent_id)
      parent_type.constantize.find(parent_id)
    rescue NameError, ActiveRecord::RecordNotFound
      nil
    end

    def parent_breadcrumb_name(parent)
      case parent.class.name
      when "Products::Cake"
        "Cake #{parent.name}"
      else
        "#{parent.class.name.humanize} #{parent.respond_to?(:name) ? parent.name : parent.id}"
      end
    end

    def library_sample_params
      params.require(:library_sample).permit(:name, :amount, :unit, :location)
    end

    def update_library_sample_params
      params.require(:inventory_library_sample)
            .permit(:name, :amount, :unit, :location, :is_active)
    end
  end
end
