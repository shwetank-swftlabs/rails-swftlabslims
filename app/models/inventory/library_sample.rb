module Inventory
  class LibrarySample < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Commentable

    belongs_to :library_sampleable, polymorphic: true, optional: true

    validates :amount, presence: true
    validates :unit, presence: true
    validates :name, presence: true
    validates :location, presence: true

    def default_label_title
      "LIBRARY SAMPLE"
    end

    def default_label_text
      [
        "Resource: #{self.library_sampleable.present? ? self.library_sampleable.name : "N/A"}",
        "Sample Name: #{name}",
      ]
    end
  end
end