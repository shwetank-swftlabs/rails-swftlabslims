module Datafileable
  extend ActiveSupport::Concern

  included do
    has_many :data_files, as: :attachable, dependent: :destroy
  end

  def default_upload_folder_id
    nil
  end
end