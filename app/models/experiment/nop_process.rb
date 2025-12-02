module Experiment
  class NopProcess < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at
    belongs_to :reactor, class_name: "Inventory::Equipment"
    belongs_to :previous_process, class_name: "Experiment::NopProcess", optional: true
    has_one :next_process, class_name: "Experiment::NopProcess", foreign_key: "previous_process_id", dependent: :nullify

    has_one :cake, class_name: "Products::Cake", dependent: :destroy
    accepts_nested_attributes_for :cake, allow_destroy: true
    
    has_many :images, as: :attachable, dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :data_files, as: :attachable, dependent: :destroy
    
    FEEDSTOCK_TYPES = Inventory::Feedstock::FEEDSTOCK_TYPES.freeze
    FEEDSTOCK_UNITS = Inventory::Feedstock::FEEDSTOCK_UNITS.freeze
    NITRIC_ACID_UNITS = {
      "ml" => "mL (Milliliters)",
      "litres" => "L (Litres)"
    }.freeze
    REACTION_TYPES = {
      "other" => "Other",
      "feedstock_rnd" => "Feedstock R&D",
      "one_tonne_reaction" => "One Tonne Reaction"
    }.freeze
    DATA_FILE_TYPES = %w[pressure_and_temp_evolution other].freeze

    validates :batch_number, presence: true, uniqueness: true
    validates :feedstock_type, presence: true, inclusion: { in: FEEDSTOCK_TYPES }
    validates :feedstock_amount, presence: true, numericality: { greater_than: 0 }
    validates :reaction_type, presence: true, inclusion: { in: REACTION_TYPES }
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
              concentrated_effluent_generated_amount: last.concentrated_effluent_generated_amount,
              concentrated_effluent_generated_ph: last.concentrated_effluent_generated_ph,
              nitric_acid_units: last.nitric_acid_units,
              created_at: last.created_at
            } : nil
          }
        end
    end

    # ---------------------------
    # Public API
    # ---------------------------

    def self.next_batch_number(feedstock_type, reactor_id, is_reusing_effluent, nop_reaction_date)
      base = base_batch_number(feedstock_type, reactor_id, nop_reaction_date)

      return base unless is_reusing_effluent

      chain_count = current_chain_count(reactor_id)

      # If frontend expects chain_count > 0, fail clearly
      raise "Effluent reuse requires an existing process chain" if chain_count.zero?

      "#{base}-eff#{chain_count}"
    end

    # Find how long the chain is for this reactor
    def self.current_chain_count(reactor_id)
      latest = Inventory::Equipment.last_nop_process(reactor_id)
      latest&.chain_count.to_i
    end

    # ---------------------------
    # Instance-level chain logic
    # ---------------------------

    def chain_count
      count = 1
      node = self

      while node.previous_process_id.present?
        node = node.previous_process
        count += 1
      end

      count
    end

    # ---------------------------
    # Private helpers
    # ---------------------------

    private

    # Build the batch number prefix (feedstock + reactor + date + count)
    def self.base_batch_number(feedstock_type, reactor_id, nop_reaction_date)
      prefix = batch_prefix(feedstock_type, reactor_id, nop_reaction_date)
      suffix_count = where("batch_number LIKE ?", "#{prefix}%").count

      suffix_count.zero? ? prefix : "#{prefix}-#{suffix_count + 1}"
    end

    # Base string used for batch construction
    def self.batch_prefix(feedstock_type, reactor_id, nop_reaction_date)
      feedstock_code = feedstock_type.to_s.upcase[0, 3]
      reactor_code   = Inventory::Equipment.find(reactor_id).code.to_s.upcase
      date_code      = nop_reaction_date.strftime("%y%m%d")

      "#{feedstock_code}#{reactor_code}#{date_code}"
    end
  end
end