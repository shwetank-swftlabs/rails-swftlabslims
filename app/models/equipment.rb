class Equipment < ApplicationRecord
  self.table_name = "equipments"

  include LocationEnum
  include EquipmentEnums

  uses_location_enum_for :equipment_location

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :equipment_type, presence: true, inclusion: { in: Equipment.equipment_types.keys }
  validates :equipment_supplier, presence: true, inclusion: { in: Equipment.equipment_suppliers.keys }
  validates :equipment_location,
            presence: true,
            inclusion: { in: Equipment.equipment_locations.keys }
  validates :created_by, presence: true
end