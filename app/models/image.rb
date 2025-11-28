class Image < ApplicationRecord
  include DefaultDescOrder
  default_desc :created_at
  include Rails.application.routes.url_helpers

  belongs_to :attachable, polymorphic: true

  validates :name, :drive_file_id, :drive_file_url, presence: true

  def served_url
    Rails.application.routes.url_helpers.polymorphic_path([attachable, self])
  end

  private

  def default_url_options
    Rails.application.routes.default_url_options
  end
end