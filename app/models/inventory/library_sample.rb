module Inventory
  class LibrarySample < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Commentable

    belongs_to :library_sampleable, polymorphic: true, optional: true
  end
end