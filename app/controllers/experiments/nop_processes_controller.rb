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
      scope = Experiments::NopProcess.includes(:reactor)

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
      @nop_process = Experiments::NopProcess.new
    end

    def batch_number
      feedstock_type_id         = params[:feedstock_type_id]
      reactor_id             = params[:reactor_id]
      is_standalone_batch    = params[:is_standalone_batch] == "true"
      nop_reaction_date      = params[:nop_reaction_date].present? ? Date.parse(params[:nop_reaction_date]) : Date.today

      batch_number = Experiments::NopProcess.next_batch_number(
        feedstock_type_id,
        reactor_id,
        is_standalone_batch,
        nop_reaction_date
      )

      render json: { batch_number: batch_number }
    end

    def edit
      add_breadcrumb "Update #{@nop_process.batch_number}", edit_experiments_nop_process_path(@nop_process)
    
      # Always start with a fresh new cake and do NOT duplicate
      @nop_process.cakes.build if @nop_process.cakes.none?(&:new_record?)
    end

    def update
      if @nop_process.completion_data_present?
        redirect_to experiments_nop_process_path(@nop_process), alert: "NOP process completion data already present."
        return
      end
      
      params_hash = edit_nop_process_params

      # Set cake name internally based on batch number
      params_hash[:cakes_attributes].each do |_, cake|
        cake[:name] = "#{@nop_process.batch_number}_Cake"
      end
      
      if @nop_process.update(params_hash)
        redirect_to experiments_nop_process_path(@nop_process), notice: "NOP process updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def select_if_standalone_batch
      add_breadcrumb "Select if Standalone Batch", select_if_standalone_batch_experiments_nop_processes_path

      if request.get?
        render :select_if_standalone_batch
      elsif request.post?
        if params[:is_new_standalone_batch] == "yes"
          redirect_to new_standalone_batch_experiments_nop_processes_path
        else
          redirect_to new_effluent_reuse_batch_experiments_nop_processes_path
        end
      end
    end

    def new_standalone_batch
      add_breadcrumb "Add New Standalone Batch", new_standalone_batch_experiments_nop_processes_path
      @nop_process = Experiments::NopProcess.new
    end

    def create_standalone_batch
      @nop_process = Experiments::NopProcess.new(create_standalone_batch_params)
      @nop_process.created_by = current_user.email

      if @nop_process.save
        redirect_to experiments_nop_processes_path, notice: "NOP process created successfully."
      else
        render :new_standalone_batch, status: :unprocessable_entity
      end
    end

    def new_effluent_reuse_batch
      add_breadcrumb "Add New Effluent Reuse Batch", new_effluent_reuse_batch_experiments_nop_processes_path
      @nop_process = Experiments::NopProcess.new
    end

    def create_effluent_reuse_batch
      @nop_process = Experiments::NopProcess.new(create_effluent_reuse_batch_params)
      @nop_process.created_by = current_user.email
      @nop_process.set_previous_process

      if @nop_process.save
        redirect_to experiments_nop_processes_path, notice: "NOP process created successfully."
      else
        render :new_effluent_reuse_batch, status: :unprocessable_entity
      end
    end

    private

    def set_nop_breadcrumbs_root
      add_breadcrumb "NOP Processes", experiments_nop_processes_path
    end

    def set_nop_process
      @nop_process = Experiments::NopProcess.find(params[:id])
    end

    def create_standalone_batch_params
      params.require(:standalone_batch).permit(
        :reactor_id,
        :nop_reaction_type_id,
        :feedstock_type_id,
        :feedstock_amount,
        :feedstock_unit,
        :feedstock_moisture_percentage,
        :nitric_acid_units,
        :final_nitric_acid_amount,
        :final_nitric_acid_molarity,
        :rotation_rate,
        :batch_number,
        :nop_reaction_date
      )
    end

    def create_effluent_reuse_batch_params
      params.require(:effluent_reuse_batch).permit(
        :reactor_id,
        :nop_reaction_type_id,
        :feedstock_type_id,
        :feedstock_amount,
        :feedstock_unit,
        :feedstock_moisture_percentage,
        :nitric_acid_units,
        :additional_nitric_acid_amount,
        :additional_nitric_acid_molarity,
        :final_nitric_acid_amount,
        :final_nitric_acid_molarity,
        :rotation_rate,
        :batch_number,
        :nop_reaction_date
      )
    end

    def edit_nop_process_params
      params.require(:edit_nop_process).permit(
        :total_reaction_time,
        :quenching_water_volume,
        :concentrated_effluent_generated_amount,
        :concentrated_effluent_generated_ph,
        :diluted_effluent_generated_amount,
        :diluted_effluent_generated_ph,
        cakes_attributes: [
          :quantity,
          :unit,
          :moisture_percentage,
          :ph
        ]
      )
    end
  end
end
