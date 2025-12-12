module Inventory
  class LibrarySamplesController < BaseController
    before_action :set_library_samples_breadcrumbs_root, only: [:index, :new, :show, :edit]
    before_action :set_library_sample, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Inventory::LibrarySample.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Filter by location
      scope = scope.where("location ILIKE ?", "%#{params[:location]}%") if params[:location].present?

      # Filter by is_active - default to active only if no filter specified
      if params[:is_active] == "true"
        scope = scope.where(is_active: true)
      elsif params[:is_active] == "false"
        scope = scope.where(is_active: false)
      elsif params[:is_active] == ""
        # "All" selected - show all records (no filter)
      else
        # Default to showing only active records when no filter is specified
        scope = scope.where(is_active: true)
      end

      # Filter by parent name (polymorphic association)
      if params[:parent_name].present?
        # Use a subquery approach for polymorphic associations
        # This handles the case where parent might be Products::Cake or other types
        parent_name_filter = params[:parent_name]
        
        # For Products::Cake (the main parent type)
        cake_ids = Products::Cake.where("name ILIKE ?", "%#{parent_name_filter}%").pluck(:id)
        
        # Build conditions for polymorphic association using safe parameterized queries
        conditions = []
        args = []
        
        if cake_ids.any?
          placeholders = cake_ids.map { "?" }.join(",")
          conditions << "(library_sampleable_type = ? AND library_sampleable_id IN (#{placeholders}))"
          args << "Products::Cake"
          args.concat(cake_ids)
        end
        
        # If no matches found for any type, scope will be empty
        if conditions.any?
          scope = scope.where(conditions.join(" OR "), *args)
        else
          # If no matches, return empty result
          scope = scope.none
        end
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
