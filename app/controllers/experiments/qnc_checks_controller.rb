module Experiments
  class QncChecksController < ApplicationController
    before_action :set_qnc_checks_breadcrumbs_root, only: [:index, :new, :show, :edit]
    before_action :set_qnc_check, only: [:show, :edit, :update, :qr_code, :mark_completed]
    before_action :set_parent, only: [:new, :create]

    def index
      scope = Experiments::QncChecks::Query.new(params).call
      @pagy, @qnc_checks = pagy(scope.order(created_at: :desc))
      @pending_qnc_checks_count = Experiments::QncCheckRequest.where(
        requested_from: current_user.email,
        is_active: true
      ).count
    end

    def new
      @qnc_check = build_qnc_check
      @qnc_check.requested_by = current_user.email
      @users = User.order(:email)

      if @parent
        prepare_parent_page
        render parent_show_template, status: :ok
      else
        add_breadcrumb "Add QNC Check Request"
      end
    end

    def show
      add_breadcrumb "QNC Check Request #{@qnc_check.name} Details",
                     experiments_qnc_check_request_path(@qnc_check)
    end

    def create
      @qnc_check = build_qnc_check
      @qnc_check.assign_attributes(qnc_check_params)
      @qnc_check.requested_by = current_user.email

      if @qnc_check.save
        redirect_to after_create_redirect_path,
                    notice: "QNC check request created successfully",
                    status: :see_other
      else
        @users = User.order(:email)
        if @parent
          prepare_parent_page
          render parent_show_template, status: :unprocessable_entity
        else
          add_breadcrumb "Add QNC Check Request"
          render :new, status: :unprocessable_entity
        end
      end
    end

    def edit
      @users = User.order(:email)
      add_breadcrumb "Edit QNC Check Request #{@qnc_check.name}",
                     edit_experiments_qnc_check_request_path(@qnc_check)
    end

    def update
      update_params = update_qnc_check_params

      if update_params[:is_active] == "true"
        update_params[:completed_at] = nil
      end
      
      if @qnc_check.update(update_params)
        redirect_to experiments_qnc_check_request_path(@qnc_check),
                    notice: "QNC check request updated successfully"
      else
        @users = User.order(:email)
        render :edit, status: :unprocessable_entity
      end
    end

    def mark_completed
      if @qnc_check.update(completed_at: Time.current, is_active: false)
        redirect_to experiments_qnc_check_request_path(@qnc_check),
                    notice: "QNC check request marked as completed successfully",
                    status: :see_other
      else
        redirect_to experiments_qnc_check_request_path(@qnc_check),
                    alert: "Failed to mark QNC check request as completed",
                    status: :see_other
      end
    end

    def qr_code
      pdf = @qnc_check.qr_label_pdf(
        url: experiments_qnc_check_request_url(@qnc_check)
      )

      send_data pdf,
                filename: "#{@qnc_check.name}_qr_code.pdf",
                type: "application/pdf",
                disposition: "inline"
    end

    private

    # --------------------
    # Setup
    # --------------------

    def set_qnc_checks_breadcrumbs_root
      add_breadcrumb "QNC Check Requests", experiments_qnc_check_requests_path
    end

    def set_qnc_check
      @qnc_check = Experiments::QncCheckRequest.find(params[:id])
    end

    def set_parent
      @parent = Experiments::QncCheckRequestParentResolver.new(params).parent
    end

    # --------------------
    # Builders
    # --------------------

    def build_qnc_check
      return Experiments::QncCheckRequest.new unless @parent

      @parent.qnc_check_requests.build
    end

    # --------------------
    # Parent helpers
    # --------------------

    def parent_show_template
      @parent.class.name.underscore.pluralize + "/show"
    end

    def after_create_redirect_path
      return experiments_qnc_check_requests_path unless @parent

      polymorphic_path(@parent, tab: :qnc_check_requests)
    end

    def prepare_parent_page
      set_parent_instance_variables
      paginate_qnc_check_requests
      @users = User.order(:email)
      params[:tab] = 'qnc_check_requests'
    end

    def set_parent_instance_variables
      # Generic assignment — views can rely on instance variable matching model name
      instance_variable_set("@#{@parent.model_name.element}", @parent)
    end

    def paginate_qnc_check_requests
      return unless @parent

      @pagy, @qnc_checks =
        pagy(@parent.qnc_check_requests.order(created_at: :desc))
    end

    def qnc_check_params
      params.require(:qnc_check)
            .permit(:name, :location, :requested_from, :expected_completion_date)
    end

    def update_qnc_check_params
      params.require(:experiments_qnc_check)
            .permit(:name, :location, :requested_from, :expected_completion_date, :is_active)
    end
  end
end


