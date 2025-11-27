module EquipmentEnums
  extend ActiveSupport::Concern
  
  included do
    enum :equipment_type, {
      reactor: "reactor",
      homogenizer: "homogenizer",
      other_equipment_type: "other_equipment_type",
    }.freeze

    enum :equipment_supplier, {
      other_equipment_supplier: "other_equipment_supplier",
    }.freeze
  end
end