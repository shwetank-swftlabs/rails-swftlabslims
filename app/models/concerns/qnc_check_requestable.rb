module QncCheckRequestable
  extend ActiveSupport::Concern

  included do
    has_many :qnc_check_requests, as: :qnc_check_requestable, dependent: :destroy, class_name: "Experiments::QncCheckRequest"
  end

  def self.qnc_check_request_names
    Admin::QncChecksConfig
      .where(resource_class: self.name, is_active: true)
      .pluck(:name)
  end
end