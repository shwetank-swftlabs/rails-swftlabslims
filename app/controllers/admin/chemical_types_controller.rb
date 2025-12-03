module Admin
  class ChemicalTypesController < BaseAdminController
    before_action :set_chemical_type, only: [:edit, :update]
    before_action :set_chemical_types_breadcrumbs_root, only: [:index, :new, :create, :edit, :update]

    def index
      @chemical_types = Admin::ChemicalType.all.order(:name)
    end

    def new
      add_breadcrumb "Add Chemical Type", new_admin_chemical_type_path
      @chemical_type = Admin::ChemicalType.new
    end

    def create
      @chemical_type = Admin::ChemicalType.new(chemical_type_params)
      @chemical_type.created_by = current_user.email

      if @chemical_type.save
        redirect_to admin_chemical_types_path, notice: "Chemical type created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit Chemical Type", edit_admin_chemical_type_path(@chemical_type)
    end

    def update
      if @chemical_type.update(chemical_type_params)
        redirect_to admin_chemical_types_path, notice: "Chemical type updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_chemical_type
      @chemical_type = Admin::ChemicalType.find(params[:id])
    end

    def chemical_type_params
      params.require(:admin_chemical_type).permit(:name, :is_active, :created_by, :created_at)
    end

    def set_chemical_types_breadcrumbs_root
      add_breadcrumb "Chemical Types", admin_chemical_types_path
    end
  end
end

