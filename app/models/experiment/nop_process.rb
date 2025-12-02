module Experiment
  class NopProcess < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at
    belongs_to :reactor, class_name: "Inventory::Equipment"

    has_one :cake, class_name: "Products::Cake", dependent: :destroy
    accepts_nested_attributes_for :cake, allow_destroy: true
    
    FEEDSTOCK_TYPES = Inventory::Feedstock::FEEDSTOCK_TYPES.freeze
    FEEDSTOCK_UNITS = Inventory::Feedstock::FEEDSTOCK_UNITS.freeze
    NITRIC_ACID_UNITS = {
      "ml" => "mL (Milliliters)",
      "litres" => "L (Litres)"
    }.freeze

    validates :batch_number, presence: true, uniqueness: true
    validates :feedstock_type, presence: true, inclusion: { in: FEEDSTOCK_TYPES }
    validates :feedstock_amount, presence: true, numericality: { greater_than: 0 }
    validates :feedstock_unit, presence: true
    validates :feedstock_moisture_percentage, presence: true
    validates :nitric_acid_units, presence: true
    validates :final_nitric_acid_amount, presence: true
    validates :final_nitric_acid_molarity, presence: true
    validates :reactor, presence: true
    validates :rotation_rate, presence: true, numericality: { greater_than: 0 }
    validates :nop_reaction_date, presence: true
    validates :created_by, presence: true

    def completion_data_present?
      total_reaction_time.present?
    end

    def self.reactors_for_nop_process
      Inventory::Equipment
        .where(equipment_type: "reactor")
        .includes(:last_nop_process)
        .map do |reactor|
          last = reactor.last_nop_process
          {
            reactor_id: reactor.id,
            reactor_name: reactor.name,
            last_batch_info: last.present? ? {
              id: last.id,
              feedstock_type: last.feedstock_type,
              batch_number: last.batch_number,
              concentrated_effluent_generated_amount: nil,
              concentrated_effluent_generated_ph: nil,
              nitric_acid_units: last.nitric_acid_units,
              created_at: last.created_at
            } : nil
          }
        end
    end

    def self.next_batch_number(feedstock_type, reactor_id, is_reusing_effluent, nop_reaction_date)
      return self.next_batch_number_without_reusing_effluent(feedstock_type, reactor_id, nop_reaction_date)
    end

    def self.next_batch_number_without_reusing_effluent(feedstock_type, reactor_id, nop_reaction_date)
      feedstock_short_name = feedstock_type.upcase.slice(0, 3)
      reactor_short_name = Inventory::Equipment.find(reactor_id).code.upcase
      formatted_date = nop_reaction_date.strftime("%y%m%d")
      batch_prefix = "#{feedstock_short_name}#{reactor_short_name}#{formatted_date}"
      count_with_same_prefix = Experiment::NopProcess.where("batch_number LIKE ?", "#{batch_prefix}%").count

      if count_with_same_prefix == 0
        return "#{batch_prefix}"
      else
        return "#{batch_prefix}-#{count_with_same_prefix + 1}"
      end
    end

    def self.next_batch_number_with_reusing_effluent(feedstock_type, reactor_id)
      "NOP-#{Experiment::NopProcess.count + 1}"
    end
  end
end