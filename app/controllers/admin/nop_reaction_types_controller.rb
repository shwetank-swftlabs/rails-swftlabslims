module Admin
  class NopReactionTypesController < BaseAdminController
    before_action :set_nop_reaction_type, only: [:edit, :update]
    before_action :set_nop_reaction_types_breadcrumbs_root, only: [:index, :new, :create, :edit, :update]

    def index
      @nop_reaction_types = Admin::NopReactionType.all.order(:name)
    end

    def new
      add_breadcrumb "Add NOP Reaction Type", new_admin_nop_reaction_type_path
      @nop_reaction_type = Admin::NopReactionType.new
    end

    def create
      @nop_reaction_type = Admin::NopReactionType.new(nop_reaction_type_params)
      @nop_reaction_type.created_by = current_user.email

      if @nop_reaction_type.save
        redirect_to admin_nop_reaction_types_path, notice: "NOP reaction type created successfully"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      add_breadcrumb "Edit NOP Reaction Type", edit_admin_nop_reaction_type_path(@nop_reaction_type)
    end

    def update
      if @nop_reaction_type.update(nop_reaction_type_params)
        redirect_to admin_nop_reaction_types_path, notice: "NOP reaction type updated successfully"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_nop_reaction_type
      @nop_reaction_type = Admin::NopReactionType.find(params[:id])
    end

    def nop_reaction_type_params
      params.require(:admin_nop_reaction_type).permit(:name, :is_active)
    end

    def set_nop_reaction_types_breadcrumbs_root
      add_breadcrumb "NOP Reaction Types", admin_nop_reaction_types_path
    end
  end
end



