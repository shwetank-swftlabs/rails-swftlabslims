class AddEquipmentTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment_types do |t|
      t.string :name, null: false
      t.string :created_by, null: false
      t.boolean :is_active, null: false, default: true
      t.timestamps
    end

    remove_column :equipments, :equipment_type, :string
    add_reference :equipments, :equipment_type, foreign_key: true
  end
end
