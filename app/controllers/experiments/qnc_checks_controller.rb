module Experiments
  class QncChecksController < ApplicationController
    before_action :set_qnc_checks_breadcrumbs_root, only: [:index, :new, :show, :edit]
    before_action :set_qnc_check, only: [:show, :edit, :update, :qr_code]

    def index
      scope = Experiments::QncCheck.all
      @pagy, @qnc_checks = pagy(scope.order(created_at: :desc))
    end

    def new
      @parent = load_qnc_checkable
      @qnc_check = build_qnc_check
      add_breadcrumb "Add QNC Check"
    end

    def show
      add_breadcrumb "QNC Check #{@qnc_check.name} Details",
                     experiments_qnc_check_path(@qnc_check)
    end

    def create
      @parent = load_qnc_checkable
      @qnc_check = build_qnc_check_from_create
      @qnc_check.assign_attributes(qnc_check_params)

      if @qnc_check.save
        redirect_to redirect_path_for(@parent),
                    notice: "QNC check created successfully",
                    status: :see_other
      else
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
      if @parent
        @parent.qnc_checks.build
      else
        Experiments::QncCheck.new
      end
    end

    def build_qnc_check_from_create
      if @parent
        @parent.qnc_checks.new
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


