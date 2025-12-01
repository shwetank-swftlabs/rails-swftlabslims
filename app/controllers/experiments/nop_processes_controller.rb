module Experiments
  class BaseController < ApplicationController
    before_action :set_experiments_breadcrumbs_root

    private

    def set_experiments_breadcrumbs_root
      add_breadcrumb "Experiments", experiments_path
    end
  end

  class NopProcessesController < BaseController
    before_action :set_nop_breadcrumbs_root

    def index
    end

    def show
    end

    def new
      add_breadcrumb "Add New NOP Process", new_experiments_nop_process_path
      @nop_process = Experiment::NopProcess.new
    end

    def create
      @nop_process = Experiment::NopProcess.new(create_nop_process_params)
      if @nop_process.save
        redirect_to experiments_nop_process_path(@nop_process), notice: "NOP process created successfully."
      else
        # Re-render the form with errors - @nop_process already has submitted attributes
        render :new, status: :unprocessable_entity
      end
    end

    def batch_number
      feedstock_type = params[:feedstock_type]
      reactor_id = params[:reactor_id]
      is_reusing_effluent = params[:is_reusing_effluent]
      nop_reaction_date = params[:nop_reaction_date].present? ? Date.parse(params[:nop_reaction_date]) : Date.today

      batch_number = Experiment::NopProcess.next_batch_number(feedstock_type, reactor_id, is_reusing_effluent, nop_reaction_date)

      render json: { batch_number: batch_number }
    end

    private
    def set_nop_breadcrumbs_root
      add_breadcrumb "NOP Processes", experiments_nop_processes_path
    end

    def create_nop_process_params
      permitted = params.require(:experiment_nop_process).permit(:feedstock_type, :feedstock_amount, :feedstock_unit, :feedstock_moisture_percentage, :nitric_acid_units, :additional_nitric_acid_amount, :additional_nitric_acid_molarity, :final_nitric_acid_amount, :final_nitric_acid_molarity, :rotation_rate, :reactor_id, :batch_number, :created_by, :nop_reaction_date)
    end
  end
end