module Experiments
  class QncCheck < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Commentable
    include Datafileable

    belongs_to :qnc_checkable, polymorphic: true, optional: true

    validates :name, presence: true
    validates :requested_by, presence: true
    validates :requested_from, 
      presence: true,
      format: { 
        with: /\A[\w+\-.]+@swftlabs\.com\z/i,
        message: "must be a valid @swftlabs.com email address"
      }
    validates :expected_completion_date, presence: true

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