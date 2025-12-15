class AddQncChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :qnc_checks_configs do |t|
      t.string :name
      t.string :resource_class
      t.string :created_by
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
