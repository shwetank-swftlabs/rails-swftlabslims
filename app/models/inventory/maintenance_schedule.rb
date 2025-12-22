module Inventory
  class MaintenanceSchedule < ApplicationRecord
    self.table_name = "maintenance_schedules"
    belongs_to :equipment, class_name: "Inventory::Equipment"

    # Validations
    validates :name, presence: true
    validates :interval_days, presence: true, numericality: { greater_than: 0 }
    validates :next_due_date, presence: true
    validates :created_by, presence: true
    validates :name, uniqueness: { scope: :equipment_id }

    # Scopes
    scope :active, -> { where(is_active: true) }
    scope :inactive, -> { where(is_active: false) }
  end
end