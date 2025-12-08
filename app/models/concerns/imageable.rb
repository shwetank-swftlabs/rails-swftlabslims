module Imageable
  extend ActiveSupport::Concern

  included do
    has_many :images, as: :attachable, dependent: :destroy
  end

  def default_upload_folder_id
    nil
  end
end

