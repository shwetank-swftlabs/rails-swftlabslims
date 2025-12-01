class CreateNopProcesses < ActiveRecord::Migration[8.1]
  def change
    create_table :nop_processes do |t|
      t.string :batch_number, null: false
      t.string :feedstock_type, null: false
      t.decimal :feedstock_amount, null: false
      t.string :feedstock_unit, null: false
      t.string :feedstock_moisture_percentage, null: false
      t.string :nitric_acid_units, null: false
      t.decimal :additional_nitric_acid_amount
      t.decimal :additional_nitric_acid_molarity
      t.decimal :final_nitric_acid_amount, null: false
      t.decimal :final_nitric_acid_molarity, null: false
      t.decimal :rotation_rate, null: false

      t.timestamps
    end
  end
end
