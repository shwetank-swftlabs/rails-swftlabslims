module Admin
  class FeedstockTypesController < BaseAdminController
    before_action :set_feedstock_type, only: [:edit, :update]
    before_action :set_feedstock_types_breadcrumbs_root, only: [:index, :new, :create, :edit, :update]

    def index
      @feedstock_types = Admin::FeedstockType.all.order(:name)
    end

    def new
      add_breadcrumb "Add Feedstock Type", new_admin_feedstock_type_path
      @feedstock_type = Admin::FeedstockType.new
    end

    def create
      @feedstock_type = Admin::FeedstockType.new(feedstock_type_params)
      @feedstock_type.created_by = current_user.email

      if @feedstock_type.save
        redirect_to admin_feedstock_types_path, notice: "Feedstock type created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit Feedstock Type", edit_admin_feedstock_type_path(@feedstock_type)
    end

    def update
      if @feedstock_type.update(feedstock_type_params)
        redirect_to admin_feedstock_types_path, notice: "Feedstock type updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_feedstock_type
      @feedstock_type = Admin::FeedstockType.find(params[:id])
    end

    def feedstock_type_params
      params.require(:admin_feedstock_type).permit(:name, :is_active)
    end

    def set_feedstock_types_breadcrumbs_root
      add_breadcrumb "Feedstock Types", admin_feedstock_types_path
    end
  end
end

