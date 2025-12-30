module Products
  class Substrate < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at
    SUBSTRATE_TYPES = %w[hydrosponge aerosponge].freeze
    SUBSTRATE_UNITS = %w[ml litres trays].freeze
    SUBSTRATE_DATA_FILE_TYPES = %w[other].freeze
    SUBSTRATE_USAGE_PURPOSES = %w[grow_trial other].freeze

    include QrLabelable
    include Usageable
    include Commentable
    include Datafileable
    include LibrarySampleable
    include QncCheckRequestable

    belongs_to :cnf, class_name: "Products::Cnf", optional: true

    validates :name, presence: true
    validates :substrate_type, presence: true, inclusion: { in: SUBSTRATE_TYPES }
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true, inclusion: { in: SUBSTRATE_UNITS }

    def default_label_title
      "SUBSTRATE"
    end

    def default_label_text
      [
        "Name: #{name}",
      ]
    end
  end
end