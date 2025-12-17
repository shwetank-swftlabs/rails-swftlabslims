module Admin
  class QncChecksConfig < ApplicationRecord
    QNC_CHECK_RESOURCE_CLASSES = [
      "Products::Cake",
      "Products::Cnf"
    ].freeze

    validates :name, presence: true
    validates :resource_class, presence: true, inclusion: { in: QNC_CHECK_RESOURCE_CLASSES }
    validates :created_by, presence: true
  
    def self.resource_class_qnc_checks(resource_class)
      Experiments::QncCheckRequest.where(qnc_check_requestable_type: resource_class)
    end
  end
end