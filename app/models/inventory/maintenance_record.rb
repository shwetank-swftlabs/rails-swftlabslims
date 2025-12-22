module Inventory
  class MaintenanceRecord < ApplicationRecord
    after_create :update_next_due_date

    self.table_name = "maintenance_records"
    belongs_to :maintenance_schedule, class_name: "Inventory::MaintenanceSchedule"

    validates :completed_at, presence: true
    validates :created_by, presence: true 

    scope :active, -> { where(is_active: true) }
    scope :inactive, -> { where(is_active: false) }
    scope :recent, -> { order(completed_at: :desc) }

    private
    def update_next_due_date
      self.maintenance_schedule.update(next_due_date: self.completed_at + self.maintenance_schedule.interval_days.days)
    end
  end
end