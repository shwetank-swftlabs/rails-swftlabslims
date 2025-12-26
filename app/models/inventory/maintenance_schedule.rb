module Inventory
  class MaintenanceSchedule < ApplicationRecord
    self.table_name = "maintenance_schedules"
    belongs_to :equipment, class_name: "Inventory::Equipment"
    has_many :maintenance_records, class_name: "Inventory::MaintenanceRecord", dependent: :destroy
    order :name, :asc

    # Validations
    validates :name, presence: true
    validates :interval_days, presence: true, numericality: { greater_than: 0 }
    validates :next_due_date, presence: true
    validates :created_by, presence: true
    validates :name, uniqueness: { scope: :equipment_id }

    # Scopes
    scope :active, -> { where(is_active: true) }
    scope :inactive, -> { where(is_active: false) }

    def last_completed_at
      maintenance_records.active.order(completed_at: :desc).first&.completed_at
    end

    # Status method - consolidates all status logic in one place
    def status
      return :up_to_date unless next_due_date.present?
      
      today = Date.today
      days_until = (next_due_date - today).to_i
      
      return :overdue if days_until < 0
      return :due_soon if days_until <= 7
      :up_to_date
    rescue TypeError, NoMethodError
      # Handle edge case where next_due_date might not be a Date (shouldn't happen, but defensive)
      :up_to_date
    end

    def status_badge_class
      case status
      when :overdue
        "bg-danger"
      when :due_soon
        "bg-warning text-dark"
      when :up_to_date
        "bg-success"
      end
    end

    def status_badge_text
      case status
      when :overdue
        "Overdue"
      when :due_soon
        "Due Soon"
      when :up_to_date
        "Up to Date"
      end
    end

    def status_icon
      case status
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