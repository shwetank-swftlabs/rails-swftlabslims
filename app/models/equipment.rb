class Equipment < ApplicationRecord
  include LocationEnum

  enum equipment_type: {
    'reactor': 'reactor',
    'homogenizer': 'homogenizer',
    'other': 'other',
  }.freeze

  enum equipment_supplier: {
    'other': 'other',
  }.freeze


  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true
  validates :equipment_type, presence: true
  validates :equipment_supplier, presence: true
  validates :location, presence: true
  validates :created_by, presence: true
end