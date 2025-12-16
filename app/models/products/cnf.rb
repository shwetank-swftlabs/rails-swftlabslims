module Products
  class Cnf < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Usageable
    include Commentable
    include Datafileable
    include LibrarySampleable
    include QncCheckable

    belongs_to :cake, class_name: "Products::Cake", optional: true

    validates :name, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true
    validates :location, presence: true
    validates :created_by, presence: true

    CNF_UNITS = {
      "ml" => "mL (Milliliters)",
      "litres" => "L (Litres)",
    }.freeze

    CNF_DATA_FILE_TYPES = %w[rheometry icp other].freeze
    USAGE_PURPOSES = %w[homogenization grow_trial other].freeze

    def default_label_title
      "CNF"
    end

    def default_label_text
      [
        "Name: #{name}",
      ]
    end
  end
end