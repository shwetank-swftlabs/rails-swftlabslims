class Admin::QncChecksConfigsController < Admin::BaseAdminController
  before_action :set_qnc_checks_config, only: [:edit, :update]
  before_action :set_qnc_checks_configs_breadcrumbs_root, only: [:index, :new, :create, :edit, :update]

  def index
    @resource_classes = Admin::QncChecksConfig::QNC_CHECK_RESOURCE_CLASSES
    @selected_resource_class = params[:resource_class].presence || @resource_classes.first

    @qnc_checks_configs = Admin::QncChecksConfig
      .where(resource_class: @selected_resource_class)
      .order(:name)
  end

  def new
    @resource_classes = Admin::QncChecksConfig::QNC_CHECK_RESOURCE_CLASSES
    selected_resource_class = params[:resource_class].presence

    unless selected_resource_class
      return redirect_to admin_qnc_checks_configs_path,
                         alert: "Please select a resource class before creating a QNC checks config."
    end

    add_breadcrumb "Add QNC Check", new_admin_qnc_checks_config_path(resource_class: selected_resource_class)

    @qnc_checks_config = Admin::QncChecksConfig.new(
      resource_class: selected_resource_class,
      is_active: true
    )
  end

  def create
    @qnc_checks_config = Admin::QncChecksConfig.new(qnc_checks_config_params)
    @qnc_checks_config.created_by = current_user.email
    @qnc_checks_config.is_active = true

    if @qnc_checks_config.save
      redirect_to admin_qnc_checks_configs_path(resource_class: @qnc_checks_config.resource_class),
                  notice: "QNC check created successfully"
    else
      add_breadcrumb "Add QNC Check", new_admin_qnc_checks_config_path(resource_class: @qnc_checks_config.resource_class)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "Edit QNC Checks Config", edit_admin_qnc_checks_config_path(@qnc_checks_config, resource_class: @qnc_checks_config.resource_class)
  end

  def update
    if @qnc_checks_config.update(update_qnc_checks_config_params)
      redirect_to admin_qnc_checks_configs_path(resource_class: @qnc_checks_config.resource_class),
                  notice: "QNC check updated successfully"
    else
      add_breadcrumb "Edit QNC Check", edit_admin_qnc_checks_config_path(@qnc_checks_config, resource_class: @qnc_checks_config.resource_class)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_qnc_checks_config
    @qnc_checks_config = Admin::QncChecksConfig.find(params[:id])
  end

  def qnc_checks_config_params
    params.require(:admin_qnc_checks_config).permit(:name, :resource_class)
  end

  def update_qnc_checks_config_params
    params.require(:admin_qnc_checks_config).permit(:name, :is_active)
  end

  def set_qnc_checks_configs_breadcrumbs_root
    add_breadcrumb "QNC Checks Configs",
                   admin_qnc_checks_configs_path(resource_class: params[:resource_class])
  end
end