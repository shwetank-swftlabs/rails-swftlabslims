module Inventory
  class Chemical < ApplicationRecord
    include QrLabelable
    include Usageable
    has_many :comments, as: :commentable, dependent: :destroy

    LOCATIONS = %w[lihti nfc other].freeze
    SUPPLIERS = %w[other].freeze
    TYPES = %w[nitric_acid other].freeze
    USAGE_PURPOSES = %w[nop_reaction other].freeze

    AMOUNT_UNITS = {
      "ml" => "mL (Milliliters)",
      "litres" => "L (Litres)",
      "grams" => "g (Grams)",
      "kg" => "kg (Kilograms)",
      "pounds" => "lb (Pounds)",
      "other" => "Other"
    }.freeze


    validates :name, presence: true, uniqueness: true
    validates :chemical_type, presence: true, inclusion: { in: TYPES }
    validates :supplier, presence: true, inclusion: { in: SUPPLIERS }
    validates :unit, presence: true, inclusion: { in: AMOUNT_UNITS.keys }
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :location, presence: true, inclusion: { in: LOCATIONS }
    validates :created_by, presence: true
    validates :is_active, inclusion: { in: [true, false] }

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