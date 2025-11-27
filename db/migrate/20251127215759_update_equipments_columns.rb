class UpdateEquipmentsColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :equipments, :short_name, :code
    rename_column :equipments, :location, :equipment_location
    add_column :equipments, :location_details, :string
  end
end
