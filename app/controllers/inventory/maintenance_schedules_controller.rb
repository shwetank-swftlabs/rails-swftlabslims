module Inventory
  class MaintenanceSchedulesController < BaseController
    before_action :set_equipment
    before_action :set_maintenance_schedule, only: [:edit, :update]
    before_action :set_breadcrumbs

    def new
      @maintenance_schedule = @equipment.maintenance_schedules.build
      @maintenance_schedule.is_active = true
    end

    def create
      @maintenance_schedule = @equipment.maintenance_schedules.build(maintenance_schedule_params)
      @maintenance_schedule.created_by = current_user.email

      if @maintenance_schedule.save
        redirect_to inventory_equipment_path(@equipment, tab: :maintenance_schedules), notice: "Maintenance schedule created successfully"
      else
        # Render equipment show page with errors so @maintenance_schedule is available
        # Set params to show the correct tab
        params[:tab] = 'maintenance_schedules'
        render 'inventory/equipments/show', status: :unprocessable_entity
      end
    end

    def edit
      # Render equipment show page with edit form visible
      params[:tab] = 'maintenance_schedules'
      params[:edit_schedule_id] = @maintenance_schedule.id
      render 'inventory/equipments/show'
    end

    def update
      if @maintenance_schedule.update(update_maintenance_schedule_params)
        redirect_to inventory_equipment_path(@equipment, tab: :maintenance_schedules), notice: "Maintenance schedule updated successfully"
      else
        # Render equipment show page with errors
        params[:tab] = 'maintenance_schedules'
        params[:edit_schedule_id] = @maintenance_schedule.id
        render 'inventory/equipments/show', status: :unprocessable_entity
      end
    end

    private

    def set_equipment
      @equipment = Inventory::Equipment.find(params[:equipment_id])
    end

    def set_maintenance_schedule
      @maintenance_schedule = @equipment.maintenance_schedules.find(params[:id])
    end

    def set_breadcrumbs
      add_breadcrumb "Equipment", inventory_equipments_path
      add_breadcrumb @equipment.name, inventory_equipment_path(@equipment)

      case action_name
      when "new", "create"
        add_breadcrumb "Add Maintenance Schedule"
      end
    end

    def maintenance_schedule_params
      params.require(:inventory_maintenance_schedule).permit(:name, :interval_days, :next_due_date, :notes)
    end

    def update_maintenance_schedule_params
      params.require(:inventory_maintenance_schedule).permit(:name, :interval_days, :next_due_date, :notes, :is_active)
    end
  end
end

