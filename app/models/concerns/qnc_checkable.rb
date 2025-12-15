module QncCheckable
  extend ActiveSupport::Concern

  included do
    has_many :qnc_checks, as: :qnc_checkable, dependent: :destroy, class_name: "Experiments::QncCheck"
  end
end