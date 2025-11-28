class AddIsActiveToEquipments < ActiveRecord::Migration[8.1]
  def change
    add_column :equipments, :is_active, :boolean, default: true
  end
end
