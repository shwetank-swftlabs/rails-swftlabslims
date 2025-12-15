class AddQncCheckable < ActiveRecord::Migration[8.1]
  def change
    create_table :qnc_checks do |t|
      t.string :name
      t.string :location
      t.boolean :is_active, default: true
      t.string :requested_by
      t.string :requested_from
      t.datetime :expected_completion_date
      t.datetime :completed_at
      t.references :qnc_checkable, polymorphic: true

      t.timestamps
    end
  end
end
