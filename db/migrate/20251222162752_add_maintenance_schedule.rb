class AddMaintenanceSchedule < ActiveRecord::Migration[8.1]
  def change
    create_table :maintenance_schedules do |t|
      t.string :name
      t.integer :interval_days
      t.date :last_completed_at
      t.date :next_due_date
      t.boolean :is_active, default: true
      t.string :created_by
      t.text :notes

      t.references :equipment, null: false, foreign_key: { to_table: :equipments, on_delete: :cascade }
      t.timestamps
    end
  end
end
