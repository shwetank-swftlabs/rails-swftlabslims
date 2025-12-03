class DropDefaultFromLocationIneEquipments < ActiveRecord::Migration[8.1]
  def change
    remove_column :equipments, :equipment_supplier, :string
    add_column :equipments, :supplier, :string
  end
end
