class DataFile < ApplicationRecord
  include DefaultDescOrder
  default_desc :created_at

  belongs_to :attachable, polymorphic: true

  validates :data_type, :file_name, :mime_type, :drive_file_id, :drive_file_url, presence: true
end