module QncCheckable
  extend ActiveSupport::Concern

  included do
    has_many :qnc_checks, as: :qnc_checkable, dependent: :destroy, class_name: "Experiments::QncCheck"
  end

  def qnc_checks_remaining
    # Get all active QNC check configs for this resource class
    active_qnc_check_names = Admin::QncChecksConfig
      .where(resource_class: self.class.name, is_active: true)
      .pluck(:name)
    
    # Get names of QNC checks that have been created for this resource
    created_check_names = qnc_checks.pluck(:name)
    
    # Return config names that don't have corresponding checks created
    active_qnc_check_names - created_check_names
  end
end