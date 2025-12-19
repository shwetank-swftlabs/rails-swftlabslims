module Admin
  class UsersController < BaseAdminController
    before_action :set_user, only: [:edit, :update]
    before_action :check_not_same_user, only: [:edit, :update]
    before_action :set_users_breadcrumbs_root, only: [:index, :edit, :update]

    def index
      scope = Admin::User.all

      # Search by email (user name)
      scope = scope.where("email ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      @pagy, @users = pagy(scope.order(:email))
    end

    def edit
      add_breadcrumb "Edit User #{@user.email}", edit_admin_user_path(@user)
    end

    def update
      if @user.update(edit_user_params)
        redirect_to admin_users_path, notice: "User updated successfully"
      else
        render :edit, status: :unprocessable_entity, flash.now: { alert: "Failed to update user: #{@user.errors.full_messages.join(", ")}" }
      end
    end

    private

    def edit_user_params
      params.require(:admin_user).permit(:is_admin)
    end
    
    def set_users_breadcrumbs_root
      add_breadcrumb "Users", admin_users_path
    end

    def check_not_same_user
      if @user.is_same_user?(current_user)
        redirect_to admin_users_path, alert: "You cannot edit your own user."
      end
    end

    def set_user
      @user = Admin::User.find(params[:id])
    end
  end
end