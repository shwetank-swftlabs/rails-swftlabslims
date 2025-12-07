module Experiments
  class NopProcess < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    belongs_to :reactor, class_name: "Inventory::Equipment"
    belongs_to :feedstock_type, class_name: "Admin::FeedstockType"
    belongs_to :nop_reaction_type, class_name: "Admin::NopReactionType"

    belongs_to :previous_process, class_name: "Experiments::NopProcess", optional: true
    has_one :next_process, class_name: "Experiments::NopProcess", foreign_key: "previous_process_id", dependent: :nullify

    include Imageable
    include Commentable
    include Datafileable

    has_one :cake, class_name: "Products::Cake", dependent: :destroy
    accepts_nested_attributes_for :cake, allow_destroy: true
    
    FEEDSTOCK_UNITS = Inventory::Feedstock::FEEDSTOCK_UNITS.freeze
    NITRIC_ACID_UNITS = {
      "ml" => "mL (Milliliters)",
      "litres" => "L (Litres)"
    }.freeze
    DATA_FILE_TYPES = %w[pressure_and_temp_evolution other].freeze

    validates :nop_reaction_type, presence: true
    validates :reactor, presence: true
    validates :feedstock_type, presence: true
    validates :batch_number, presence: true, uniqueness: true
    validates :feedstock_amount, presence: true, numericality: { greater_than: 0 }
    validates :feedstock_unit, presence: true
    validates :feedstock_moisture_percentage, presence: true
    validates :nitric_acid_units, presence: true
    validates :final_nitric_acid_amount, presence: true
    validates :final_nitric_acid_molarity, presence: true
    validates :rotation_rate, presence: true, numericality: { greater_than: 0 }
    validates :nop_reaction_date, presence: true

    def completion_data_present?
      total_reaction_time.present?
    end

    def set_previous_process
      previous_process = Inventory::Equipment.find(self.reactor_id).last_nop_process
      if previous_process.present?
        self.previous_process = previous_process
      else
        raise "No previous process found for reactor #{self.reactor_id}"
      end
    end

    def common_nop_processes
      processes = []
      root = find_root

      # Step 2: Traverse forward from root to collect all processes in the chain
      node = root
      while node.present?
        processes << node
        node = node.next_process
      end
      
      processes
    end

    def standalone_batch?
      return true if previous_process.blank? && next_process.blank?
    end

    # ---------------------------
    # Public API
    # ---------------------------

    def self.next_batch_number(feedstock_type_id, reactor_id, is_standalone_batch, nop_reaction_date)
      base = base_batch_number(feedstock_type_id, reactor_id, nop_reaction_date)
      return base if is_standalone_batch

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
    def self.base_batch_number(feedstock_type_id, reactor_id, nop_reaction_date)
      prefix = batch_prefix(feedstock_type_id, reactor_id, nop_reaction_date)
      suffix_count = where("batch_number LIKE ?", "#{prefix}%").count

      suffix_count.zero? ? prefix : "#{prefix}-#{suffix_count + 1}"
    end

    # Base string used for batch construction
    def self.batch_prefix(feedstock_type_id, reactor_id, nop_reaction_date)
      feedstock_code = Admin::FeedstockType.find(feedstock_type_id).name.to_s.upcase.first(3)
      reactor_code   = Inventory::Equipment.find(reactor_id).code.to_s.upcase
      date_code      = nop_reaction_date.strftime("%y%m%d")

      "#{feedstock_code}#{reactor_code}#{date_code}"
    end

    def find_root
      node = self
      while node.previous_process_id.present?
        node = node.previous_process
      end
      node
    end
  end
end

