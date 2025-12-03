module Inventory
  class Feedstock < ApplicationRecord
    include DefaultDescOrder
    include QrLabelable
    include Usageable
    default_desc :updated_at

    has_many :images, as: :attachable, dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :data_files, as: :attachable, dependent: :destroy
    belongs_to :feedstock_type, class_name: "Admin::FeedstockType"

    FEEDSTOCK_UNITS = {
      "kg" => "kg (Kilograms)",
      "g" => "g (Grams)",
      "lb" => "lb (Pounds)"
    }.freeze
    USAGE_PURPOSES = %w[nop_reaction other].freeze
    FILE_DATA_TYPES = %w[other].freeze
    
    validates :feedstock_type_id, presence: true
    validates :name, presence: true, uniqueness: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true, inclusion: { in: FEEDSTOCK_UNITS.keys }
    validates :created_by, presence: true

    def default_label_title
      "FEEDSTOCK: #{feedstock_type.humanize}"
    end

    def default_label_text
      [
        "Name: #{name}",
      ]
    end
  end
end