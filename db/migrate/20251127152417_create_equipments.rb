class CreateEquipments < ActiveRecord::Migration[8.1]
  def change
    create_table :equipments do |t|
      t.string :equipment_type, null: false, default: 'other'
      t.string :name, null: false
      t.string :short_name, null: false
      t.string :location, null: false, default: 'other'
      t.string :equipment_supplier, null: false, default: 'other'
      t.string :created_by, null: false

      t.timestamps
    end
  end
end
