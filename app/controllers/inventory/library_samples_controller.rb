module Inventory
  class LibrarySamplesController < BaseController
    before_action :set_library_samples_breadcrumbs_root, only: [:index, :new, :show, :edit]
    before_action :set_library_sample, only: [:show, :edit, :update, :qr_code]
    before_action :set_parent, only: [:new, :create]

    def index
      scope = Inventory::LibrarySample.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Filter by location
      scope = scope.where("location ILIKE ?", "%#{params[:location]}%") if params[:location].present?

      # Filter by parent name (using model scope)
      scope = scope.filtered_by_parent_name(params[:parent_name]) if params[:parent_name].present?

      # Filter by is_active (only when param is present)
      if params[:is_active].present?
        is_active_value = params[:is_active] == "true"
        scope = scope.where(is_active: is_active_value)
      end

      @pagy, @library_samples = pagy(scope.order(created_at: :desc))
    end

    def new
      @library_sample = build_library_sample

      if @parent
        prepare_parent_page
        render parent_show_template, status: :ok
      else
        add_breadcrumb "Add Library Sample"
      end
    end

    def show
      add_breadcrumb "Library Sample #{@library_sample.name} Details",
                     inventory_library_sample_path(@library_sample)
    end

    def create
      @library_sample = build_library_sample
      @library_sample.assign_attributes(library_sample_params)
      @library_sample.created_by = current_user.email

      if @library_sample.save
        redirect_to after_create_redirect_path,
                    notice: "Library sample created successfully",
                    status: :see_other
      else
        if @parent
          prepare_parent_page
          render parent_show_template, status: :unprocessable_entity
        else
          add_breadcrumb "Add Library Sample"
          render :new, status: :unprocessable_entity
        end
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

    # --------------------
    # Setup
    # --------------------

    def set_library_samples_breadcrumbs_root
      add_breadcrumb "Library Samples", inventory_library_samples_path
    end

    def set_library_sample
      @library_sample = Inventory::LibrarySample.find(params[:id])
    end

    def set_parent
      @parent = Inventory::LibrarySampleParentResolver.new(params).parent
    end

    # --------------------
    # Builders
    # --------------------

    def build_library_sample
      return Inventory::LibrarySample.new unless @parent

      @parent.library_samples.build.tap do |sample|
        sample.unit ||= @parent.try(:unit)
      end
    end

    # --------------------
    # Parent helpers
    # --------------------

    def parent_show_template
      @parent.class.name.underscore.pluralize + "/show"
    end

    def after_create_redirect_path
      return inventory_library_samples_path unless @parent

      polymorphic_path(@parent, tab: :library_samples)
    end

    def prepare_parent_page
      set_parent_instance_variables
      paginate_library_samples
      params[:tab] = 'library_samples'
    end

    def set_parent_instance_variables
      # Generic assignment — views can rely on instance variable matching model name
      instance_variable_set("@#{@parent.model_name.element}", @parent)
    end

    def paginate_library_samples
      return unless @parent

      @pagy, @library_samples =
        pagy(@parent.library_samples.order(created_at: :desc))
    end

    # --------------------
    # Strong params
    # --------------------

    def library_sample_params
      params.require(:inventory_library_sample)
            .permit(:name, :amount, :unit, :location, :created_at)
    end

    def update_library_sample_params
      params.require(:inventory_library_sample)
            .permit(:name, :amount, :unit, :location, :created_at, :is_active)
    end
  end
end
