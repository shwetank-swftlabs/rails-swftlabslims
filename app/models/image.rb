class Image < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  validates :name, :drive_file_id, :drive_file_url, presence: true
end