module Inventory
  class Feedstock < ApplicationRecord
    include DefaultDescOrder
    include QrLabelable
    include Usageable
    default_desc :updated_at

    has_many :images, as: :attachable, dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy

    FEEDSTOCK_UNITS = {
      "kg" => "kg (Kilograms)",
      "g" => "g (Grams)",
      "mg" => "mg (Milligrams)",
      "lb" => "lb (Pounds)",
      "other" => "Other"
    }.freeze
    FEEDSTOCK_TYPES = %w[jute cow_manure other].freeze
    USAGE_PURPOSES = %w[nop_reaction other].freeze
    
    validates :name, presence: true, uniqueness: true
    validates :feedstock_type, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true, inclusion: { in: FEEDSTOCK_UNITS.keys }
    validates :created_by, presence: true

    def default_label_title
      "FEEDSTOCK: #{feedstock_type.humanize}"
    end

    def default_label_text
      [
        "Name: #{name}",
      ]
    end
  end
end