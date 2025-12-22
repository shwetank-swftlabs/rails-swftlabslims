module Inventory
  class Equipment < ApplicationRecord
    self.table_name = "equipments"
    include DefaultDescOrder
    default_desc :updated_at

    include QrLabelable
    include Imageable
    include Commentable
    include Datafileable

    belongs_to :equipment_type, class_name: "Admin::EquipmentType", optional: false

    has_many :nop_processes, class_name: "Experiments::NopProcess", foreign_key: "reactor_id", dependent: :destroy
    has_one :last_nop_process, -> { order(created_at: :desc) },
    class_name: "Experiments::NopProcess",
    foreign_key: :reactor_id
    has_many :maintenance_schedules, class_name: "Inventory::MaintenanceSchedule", dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :code, presence: true, uniqueness: true
    validates :created_by, presence: true
    
    def default_label_title
      name.upcase
    end

    scope :reactor, -> { joins(:equipment_type).where(equipment_types: { name: "reactor" }).where(is_active: true) }

    def self.reactors
      where(equipment_type: { name: "reactor" }, is_active: true).includes(:equipment_type).map do |reactor|
        reactor.as_json.merge(
          "last_nop_process" => last_nop_process(reactor.id).as_json
        )
      end
    end
    
    
    def self.last_nop_process(reactor_id)
      Experiments::NopProcess.where(reactor_id: reactor_id).order(created_at: :desc).first
    end

    def maintenance_status
      active_schedules = maintenance_schedules.active
      return :up_to_date if active_schedules.empty?
      
      statuses = active_schedules.map(&:status)
      
      # Priority: overdue > due_soon > up_to_date
      return :overdue if statuses.include?(:overdue)
      return :due_soon if statuses.include?(:due_soon)
      :up_to_date
    end
    
    def maintenance_status_badge_class
      case maintenance_status
      when :overdue
        "bg-danger"
      when :due_soon
        "bg-warning text-dark"
      when :up_to_date
        "bg-success"
      end
    end
    
    def maintenance_status_badge_text
      case maintenance_status
      when :overdue
        "Overdue"
      when :due_soon
        "Due Soon"
      when :up_to_date
        "Up to Date"
      end
    end
    
    def maintenance_status_icon
      case maintenance_status
      when :overdue
        "bi-exclamation-triangle"
      when :due_soon
        "bi-clock"
      when :up_to_date
        "bi-check-circle"
      end
    end
  end
end