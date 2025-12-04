module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :attachable, dependent: :destroy
  end
end

