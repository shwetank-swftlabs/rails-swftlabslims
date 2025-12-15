module Experiments
  class QncChecksController < ApplicationController
    before_action :set_qnc_checks_breadcrumbs_root, only: [:index, :new, :show, :edit]
    before_action :set_qnc_check, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Experiments::QncCheck.all

      # Search by name
      scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Filter by location
      scope = scope.where("location ILIKE ?", "%#{params[:location]}%") if params[:location].present?

      # Filter by requested_by
      scope = scope.where("requested_by ILIKE ?", "%#{params[:requested_by]}%") if params[:requested_by].present?

      # Filter by parent name (polymorphic association)
      if params[:parent_name].present?
        parent_name_filter = params[:parent_name]

        cake_ids = Products::Cake.where("name ILIKE ?", "%#{parent_name_filter}%").pluck(:id)

        conditions = []
        args = []

        if cake_ids.any?
          placeholders = cake_ids.map { "?" }.join(",")
          conditions << "(qnc_checkable_type = ? AND qnc_checkable_id IN (#{placeholders}))"
          args << "Products::Cake"
          args.concat(cake_ids)
        end

        if conditions.any?
          scope = scope.where(conditions.join(" OR "), *args)
        else
          scope = scope.none
        end
      end

      @pagy, @qnc_checks = pagy(scope.order(created_at: :desc))
    end

    def new
      @qnc_checkable = load_qnc_checkable
      @parent = @qnc_checkable
      @qnc_check = build_qnc_check

      if @qnc_checkable
        add_breadcrumb parent_breadcrumb_name(@qnc_checkable),
                       polymorphic_path(@qnc_checkable)
      end

      add_breadcrumb "Add QNC Check"
    end

    def show
      add_breadcrumb "QNC Check #{@qnc_check.name} Details",
                     experiments_qnc_check_path(@qnc_check)
    end

    def create
      @qnc_checkable = load_qnc_checkable
      @qnc_check = build_qnc_check_from_create
      @qnc_check.assign_attributes(qnc_check_params)
      @qnc_check.created_by = current_user.email if @qnc_check.respond_to?(:created_by=)

      if @qnc_check.save
        redirect_to redirect_path_for(@qnc_checkable),
                    notice: "QNC check created successfully",
                    status: :see_other
      else
        @parent = @qnc_checkable
        if @qnc_checkable
          add_breadcrumb parent_breadcrumb_name(@qnc_checkable),
                         polymorphic_path(@qnc_checkable)
        end

        add_breadcrumb "Add QNC Check"
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit QNC Check #{@qnc_check.name}",
                     edit_experiments_qnc_check_path(@qnc_check)
    end

    def update
      if @qnc_check.update(update_qnc_check_params)
        redirect_to experiments_qnc_check_path(@qnc_check),
                    notice: "QNC check updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def qr_code
      pdf = @qnc_check.qr_label_pdf(
        url: experiments_qnc_check_url(@qnc_check)
      )

      send_data pdf,
                filename: "#{@qnc_check.name}_qr_code.pdf",
                type: "application/pdf",
                disposition: "inline"
    end

    private

    def set_qnc_checks_breadcrumbs_root
      add_breadcrumb "QNC Checks", experiments_qnc_checks_path
    end

    def set_qnc_check
      @qnc_check = Experiments::QncCheck.find(params[:id])
    end

    def load_qnc_checkable
      return unless params[:parent_type].present? && params[:parent_id].present?

      params[:parent_type].constantize.find(params[:parent_id])
    rescue NameError, ActiveRecord::RecordNotFound
      nil
    end

    def build_qnc_check
      if @qnc_checkable
        @qnc_checkable.qnc_checks.build
      else
        Experiments::QncCheck.new
      end
    end

    def build_qnc_check_from_create
      if @qnc_checkable
        @qnc_checkable.qnc_checks.new
      else
        Experiments::QncCheck.new
      end
    end

    def redirect_path_for(parent)
      if parent
        polymorphic_path(parent, tab: :qnc_checks)
      else
        experiments_qnc_checks_path
      end
    end

    def parent_breadcrumb_name(parent)
      case parent.class.name
      when "Products::Cake"
        "Cake #{parent.name}"
      else
        "#{parent.class.name.humanize} #{parent.respond_to?(:name) ? parent.name : parent.id}"
      end
    end

    def qnc_check_params
      params.require(:qnc_check)
            .permit(:name, :location, :requested_by, :requested_from, :expected_completion_date)
    end

    def update_qnc_check_params
      params.require(:experiments_qnc_check)
            .permit(:name, :location, :requested_by, :requested_from, :expected_completion_date)
    end
  end
end


