class DataFile < ApplicationRecord
  include DefaultDescOrder
  default_desc :created_at
  before_validation :set_public_token

  belongs_to :attachable, polymorphic: true

  validates :data_type, :file_name, :mime_type, :drive_file_id, :drive_file_url, presence: true
  validates :public_token, presence: true, if: -> { is_public? && pdf? }
  validates :public_token, uniqueness: true, allow_nil: true

  def regenerate_public_token!
    update!(public_token: SecureRandom.uuid)
  end

  def pdf?
    mime_type == 'application/pdf' || file_name.to_s.downcase.end_with?('.pdf')
  end

  private

  def set_public_token
    if is_public? && pdf?
      # Only generate token if it doesn't exist yet (and only for PDFs)
      self.public_token ||= SecureRandom.uuid
    elsif !is_public?
      # Clear token when making private
      self.public_token = nil
    end
    # If not PDF, leave token as is (should be nil anyway)
  end
end