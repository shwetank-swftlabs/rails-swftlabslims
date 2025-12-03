class ModifyLocationInEquipment < ActiveRecord::Migration[8.1]
  def change
    remove_column :equipments, :equipment_location, :string
    remove_column :equipments, :location_details, :string
    add_column :equipments, :location, :string
  end
end
