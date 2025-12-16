module Experiments
  class QncCheck < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Commentable
    include Datafileable

    belongs_to :qnc_checkable, polymorphic: true, optional: true

    DATA_FILE_TYPES = %w[other].freeze

    validates :name, presence: true
    validates :requested_by, presence: true
    validates :requested_from, 
      presence: true,
      format: { 
        with: /\A[\w+\-.]+@swftlabs\.com\z/i,
        message: "must be a valid @swftlabs.com email address"
      }
    validates :expected_completion_date, presence: true

    def self.qnc_check_names(parent_type = nil)
      if parent_type.present?
        Admin::QncChecksConfig
          .where(resource_class: parent_type, is_active: true)
          .order(:name)
          .pluck(:name)
      else
        []
      end
    end

    def default_label_title
      "QNC CHECK SAMPLE"
    end

    def default_label_text
      [
        "Name: #{name}" 
      ]
    end
  end
end