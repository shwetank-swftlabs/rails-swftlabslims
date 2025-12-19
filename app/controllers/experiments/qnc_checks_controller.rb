module Experiments
  class QncChecksController < ApplicationController
    before_action :set_qnc_checks_breadcrumbs_root, only: [:index, :new, :show, :edit]
    before_action :set_qnc_check, only: [:show, :edit, :update, :qr_code, :mark_completed]

    def index
      scope = Experiments::QncChecks::Query.new(params).call
      @pagy, @qnc_checks = pagy(scope.order(created_at: :desc))
      @pending_qnc_checks_count = Experiments::QncCheckRequest.where(
        requested_from: current_user.email,
        is_active: true
      ).count
    end

    def new
      @parent = load_qnc_check_requestable
      @qnc_check = build_qnc_check
      @qnc_check.requested_by = current_user.email
      @users = User.order(:email)
      add_breadcrumb "Add QNC Check Request"
    end

    def show
      add_breadcrumb "QNC Check Request #{@qnc_check.name} Details",
                     experiments_qnc_check_path(@qnc_check)
    end

    def create
      @parent = load_qnc_check_requestable
      @qnc_check = build_qnc_check_from_create
      @qnc_check.assign_attributes(qnc_check_params)
      @qnc_check.requested_by = current_user.email

      if @qnc_check.save
        redirect_to redirect_path_for(@parent),
                    notice: "QNC check request created successfully",
                    status: :see_other
      else
        @users = User.order(:email)
        add_breadcrumb "Add QNC Check Request"
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @users = User.order(:email)
      add_breadcrumb "Edit QNC Check Request #{@qnc_check.name}",
                     edit_experiments_qnc_check_path(@qnc_check)
    end

    def update
      update_params = update_qnc_check_params

      if update_params[:is_active] == "true"
        update_params[:completed_at] = nil
      end
      
      if @qnc_check.update(update_params)
        redirect_to experiments_qnc_check_path(@qnc_check),
                    notice: "QNC check request updated successfully"
      else
        @users = User.order(:email)
        render :edit, status: :unprocessable_entity
      end
    end

    def mark_completed
      if @qnc_check.update(completed_at: Time.current, is_active: false)
        redirect_to experiments_qnc_check_path(@qnc_check),
                    notice: "QNC check request marked as completed successfully",
                    status: :see_other
      else
        redirect_to experiments_qnc_check_path(@qnc_check),
                    alert: "Failed to mark QNC check request as completed",
                    status: :see_other
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
      add_breadcrumb "QNC Check Requests", experiments_qnc_checks_path
    end

    def set_qnc_check
      @qnc_check = Experiments::QncCheckRequest.find(params[:id])
    end

    def load_qnc_check_requestable
      return unless params[:parent_type].present? && params[:parent_id].present?

      params[:parent_type].constantize.find(params[:parent_id])
    rescue NameError, ActiveRecord::RecordNotFound
      nil
    end

    def build_qnc_check
      if @parent
        @parent.qnc_check_requests.build
      else
        Experiments::QncCheckRequest.new
      end
    end

    def build_qnc_check_from_create
      if @parent
        @parent.qnc_check_requests.new
      else
        Experiments::QncCheckRequest.new
      end
    end

    def redirect_path_for(parent)
      if parent
        polymorphic_path(parent, tab: :qnc_check_requests)
      else
        experiments_qnc_checks_path
      end
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


