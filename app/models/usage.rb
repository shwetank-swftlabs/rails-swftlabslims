class Usage < ApplicationRecord
  belongs_to :resource, polymorphic: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :purpose, presence: true
  validates :created_by,
    presence: true,
    format: {
      with: /\A[A-Za-z0-9._%+-]+@swftlabs\.com\z/,
      message: "must be a valid SWFTLabs email address ending with @swftlabs.com"
    }
end