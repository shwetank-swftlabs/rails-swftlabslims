module Inventory
  class Chemical < ApplicationRecord
    include DefaultDescOrder
    default_desc :updated_at

    include QrLabelable
    include Usageable
    include Commentable

    belongs_to :chemical_type, class_name: "Admin::ChemicalType", optional: false
    belongs_to :parent_chemical, class_name: "Inventory::Chemical", optional: true
    has_many :derived_chemicals, class_name: "Inventory::Chemical", foreign_key: "parent_chemical_id", dependent: :nullify

    USAGE_PURPOSES = %w[nop_reaction].freeze

    validates :name, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true, inclusion: { in: AMOUNT_UNITS.keys }
    validates :chemical_type, presence: true

    validate :cannot_be_parent_of_itself

    def default_label_title
      "CHEMICAL: #{chemical_type.name.humanize}"
    end

    def default_label_text
      [
        "Name: #{name}",
      ]
    end

    private

    def cannot_be_parent_of_itself
      if parent_chemical_id == id
        errors.add(:parent_chemical, "cannot be the same as the current chemical")
      end
    end
  end
end