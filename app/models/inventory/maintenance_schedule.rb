module Inventory
  class MaintenanceSchedule < ApplicationRecord
    self.table_name = "maintenance_schedules"
    belongs_to :equipment, class_name: "Inventory::Equipment"
    has_many :maintenance_records, class_name: "Inventory::MaintenanceRecord", dependent: :destroy

    # Validations
    validates :name, presence: true
    validates :interval_days, presence: true, numericality: { greater_than: 0 }
    validates :next_due_date, presence: true
    validates :created_by, presence: true
    validates :name, uniqueness: { scope: :equipment_id }

    # Scopes
    scope :active, -> { where(is_active: true) }
    scope :inactive, -> { where(is_active: false) }
    scope :overdue, -> { where('next_due_date < ?', Date.today) }
    scope :due_soon, -> { where('next_due_date >= ? AND next_due_date <= ?', Date.today, Date.today + 7.days) }
    scope :up_to_date, -> { where('next_due_date > ?', Date.today + 7.days) }

    def last_completed_at
      maintenance_records.active.order(completed_at: :desc).first&.completed_at
    end

    # Status methods
    def overdue?
      next_due_date.present? && next_due_date < Date.today
    end

    def due_soon?
      return false unless next_due_date.present?
      next_due_date >= Date.today && next_due_date <= Date.today + 7.days
    end

    def up_to_date?
      return false unless next_due_date.present?
      next_due_date > Date.today + 7.days
    end

    def status
      return :overdue if overdue?
      return :due_soon if due_soon?
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