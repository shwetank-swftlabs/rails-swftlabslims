module Datafileable
  extend ActiveSupport::Concern

  included do
    has_many :data_files, as: :attachable, dependent: :destroy
  end
end