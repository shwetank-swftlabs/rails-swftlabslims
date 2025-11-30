class AddChemicals < ActiveRecord::Migration[8.1]
  def change
    create_table :chemicals do |t|
      t.string :name, null: false
      t.string :chemical_type, null: false
      t.date  :expiry_date

      t.decimal :quantity, null: false
      t.string :unit, null: false

      t.string :location
      t.string :location_details

      t.boolean :is_active, null: false, default: true
      t.string :supplier
      t.string :created_by, null: false, default: "system"
      t.timestamps
    end
  end
end
