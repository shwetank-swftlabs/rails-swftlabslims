module QncCheckRequestable
  extend ActiveSupport::Concern

  included do
    has_many :qnc_check_requests, as: :qnc_check_requestable, dependent: :destroy, class_name: "Experiments::QncCheckRequest"
  end

  class_methods do
    def qnc_check_request_names
      Admin::QncChecksConfig
        .where(resource_class: self.name, is_active: true)
        .pluck(:name)
    end
  end

  def qnc_check_request_names_without_samples
    self.class.qnc_check_request_names - qnc_check_requests.pluck(:name)
  end
end