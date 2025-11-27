class Equipment < ApplicationRecord
  self.table_name = "equipments"
  include LocationEnum

  enum :equipment_type, {
    'reactor': 'reactor',
    'homogenizer': 'homogenizer',
    other_equipment_type: 'other_equipment_type',
  }.freeze

  enum :equipment_supplier, {
    other_equipment_supplier: 'other_equipment_supplier',
  }.freeze


  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true
  validates :equipment_type, presence: true
  validates :equipment_supplier, presence: true
  validates :location, presence: true
  validates :created_by, presence: true
end