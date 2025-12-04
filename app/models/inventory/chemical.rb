module Inventory
  class Chemical < ApplicationRecord
    include DefaultDescOrder
    default_desc :updated_at

    include QrLabelable
    include Usageable
    include Commentable
    belongs_to :chemical_type, class_name: "Admin::ChemicalType", optional: false

    USAGE_PURPOSES = %w[nop_reaction other].freeze

    validates :name, presence: true, uniqueness: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true, inclusion: { in: AMOUNT_UNITS.keys }
    validates :chemical_type, presence: true

    def default_label_title
      "#{chemical_type.humanize}"
    end

    def default_label_text
      [
        "Name: #{name}",
      ]
    end
  end
end