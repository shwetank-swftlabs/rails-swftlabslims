class AddMaintenanceHistory < ActiveRecord::Migration[8.1]
  def up
    unless table_exists?(:maintenance_records)
      create_table :maintenance_records do |t|
        t.references :maintenance_schedule, null: false, foreign_key: { to_table: :maintenance_schedules, on_delete: :cascade }
        t.date :completed_at
        t.string :created_by
        t.text :notes
        t.boolean :is_active, default: true

        t.timestamps
      end
    end

    # Only remove column if it exists
    if column_exists?(:maintenance_schedules, :last_completed_at)
      remove_column :maintenance_schedules, :last_completed_at
    end
  end

  def down
    drop_table :maintenance_records if table_exists?(:maintenance_records)
    
    unless column_exists?(:maintenance_schedules, :last_completed_at)
      add_column :maintenance_schedules, :last_completed_at, :date
    end
  end
end

