module Products
  class Cake < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Usageable
    include Commentable

    
    CAKE_UNITS = {
      "kg" => "kg (Kilograms)",
      "g" => "g (Grams)",
    }.freeze
    CAKE_DATA_FILE_TYPES = %w[rheometry icp other].freeze
    USAGE_PURPOSES = %w[homogenization grow_trial other].freeze

    belongs_to :nop_process, class_name: "Experiments::NopProcess"

    validates :name, presence: true, uniqueness: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true
    validates :moisture_percentage, presence: true, numericality: { greater_than: 0 }
    validates :ph, presence: true, numericality: { greater_than: 0 }
  end
end