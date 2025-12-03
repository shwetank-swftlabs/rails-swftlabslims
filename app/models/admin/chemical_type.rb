module Admin
  class ChemicalType < ApplicationRecord
    validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]+\z/, message: "only lowercase letters, numbers, and underscores are allowed" }
    validates :is_active, inclusion: { in: [true, false] }
  end
end

