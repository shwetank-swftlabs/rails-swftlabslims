module Products
  class Cake < ApplicationRecord
    attr_accessor :batch_number

    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Usageable
    include Commentable
    include Datafileable
    include LibrarySampleable
    include QncCheckRequestable
    has_many :cnfs, class_name: "Products::Cnf", dependent: :destroy

    
    CAKE_UNITS = {
      "kg" => "kg (Kilograms)",
      "g" => "g (Grams)",
    }.freeze
    CAKE_DATA_FILE_TYPES = %w[rheometry icp other].freeze
    USAGE_PURPOSES = %w[homogenization grow_trial other].freeze

    belongs_to :nop_process, class_name: "Experiments::NopProcess", optional: true

    validate :validate_batch_number

    validates :name, presence: true, uniqueness: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true
    validates :moisture_percentage, presence: true, numericality: { greater_than: 0 }
    validates :ph, presence: true, numericality: { greater_than: 0 }

    def batch_number
      nop_process&.batch_number
    end

    def default_label_text
      [
        "Batch Number: #{batch_number || "N/A"}",
      ]
    end

    def default_label_title
      "CAKE: #{name}"
    end

    private

    def validate_batch_number
      return if @batch_number.blank?

      nop_process = Experiments::NopProcess.find_by(batch_number: @batch_number)

      if nop_process.nil?
        errors.add(:batch_number, "is invalid - no NOP process found with this batch number")
      elsif nop_process.cake.present?
        errors.add(:batch_number, "is invalid - a cake already exists for this batch number")
      else
        self.nop_process = nop_process
      end
    end
  end
end