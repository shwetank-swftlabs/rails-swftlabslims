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
    before_action :set_nop_process, only: [:show, :edit, :update]

    def index
      scope = Experiment::NopProcess.includes(:reactor)

      # Search by batch_number
      scope = scope.where("batch_number ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Filter by reactor (reactor id)
      if params[:reactor_id].present?
        scope = scope.where(reactor_id: params[:reactor_id])
      end

      # Filter by feedstock_type
      scope = scope.where(feedstock_type: params[:feedstock_type]) if params[:feedstock_type].present?

      @pagy, @nop_processes = pagy(scope.order(created_at: :desc), items: 15)
    end

    def show
      add_breadcrumb "#{@nop_process.batch_number} Details", experiments_nop_process_path(@nop_process)
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
        render :new, status: :unprocessable_entity
      end
    end

    def batch_number
      feedstock_type         = params[:feedstock_type]
      reactor_id             = params[:reactor_id]
      is_reusing_effluent    = params[:is_reusing_effluent]
      nop_reaction_date      = params[:nop_reaction_date].present? ? Date.parse(params[:nop_reaction_date]) : Date.today

      batch_number = Experiment::NopProcess.next_batch_number(
        feedstock_type,
        reactor_id,
        is_reusing_effluent,
        nop_reaction_date
      )

      render json: { batch_number: batch_number }
    end

    def edit
      add_breadcrumb "Update #{@nop_process.batch_number}", edit_experiments_nop_process_path(@nop_process)
      @nop_process.build_cake unless @nop_process.cake.present?
    end

    def update
      if @nop_process.completion_data_present?
        redirect_to experiments_nop_process_path(@nop_process), alert: "NOP process completion data already present."
        return
      end
      
      params_hash = edit_nop_process_params

      # Set cake name internally based on batch number
      params_hash[:cake_attributes][:name] = "#{@nop_process.batch_number}-Cake"
      
      if @nop_process.update(params_hash)
        redirect_to experiments_nop_process_path(@nop_process), notice: "NOP process updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_nop_breadcrumbs_root
      add_breadcrumb "NOP Processes", experiments_nop_processes_path
    end

    def set_nop_process
      @nop_process = Experiment::NopProcess.find(params[:id])
    end

    def create_nop_process_params
      params.require(:experiment_nop_process).permit(
        :feedstock_type,
        :feedstock_amount,
        :feedstock_unit,
        :feedstock_moisture_percentage,
        :nitric_acid_units,
        :additional_nitric_acid_amount,
        :additional_nitric_acid_molarity,
        :final_nitric_acid_amount,
        :final_nitric_acid_molarity,
        :rotation_rate,
        :reactor_id,
        :batch_number,
        :created_by,
        :nop_reaction_date
      )
    end

    def edit_nop_process_params
      params.require(:experiment_nop_process).permit(
        :total_reaction_time,
        :quenching_water_volume,
        :concentrated_effluent_generated_amount,
        :concentrated_effluent_generated_ph,
        :diluted_effluent_generated_amount,
        :diluted_effluent_generated_ph,
        cake_attributes: [
          :id,
          :quantity,
          :unit,
          :moisture_percentage,
          :ph
        ]
      )
    end
  end
end
