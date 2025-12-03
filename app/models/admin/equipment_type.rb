module Admin
  class EquipmentType < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :is_active, inclusion: { in: [true, false] }
  end
end