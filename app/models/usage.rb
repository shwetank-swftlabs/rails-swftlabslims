class Usage < ApplicationRecord
  belongs_to :resource, polymorphic: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :purpose, presence: true
  validates :created_by, presence: true
end