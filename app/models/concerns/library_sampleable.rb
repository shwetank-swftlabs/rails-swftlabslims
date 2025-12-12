module LibrarySampleable
  extend ActiveSupport::Concern

  included do
    has_many :library_samples, as: :library_sampleable, dependent: :destroy, class_name: "Inventory::LibrarySample"
  end
end