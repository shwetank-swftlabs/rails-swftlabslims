require "googleauth"
require "google/apis/drive_v3"

class GoogleDriveService
  SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

  def initialize
    @drive = Google::Apis::DriveV3::DriveService.new
    
    json_key = Rails.application.credentials.google.service_account_credentials
    raise "Google service account credentials not found" if json_key.blank?

    @drive.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(json_key),
      scope: SCOPE
    )
  end

  def upload(file, folder_id = root_folder_id)
    metadata = {
      name: file.respond_to?(:original_filename) ? file.original_filename : File.basename(file),
      parents: [folder_id]
    }

    @drive.create_file(
      metadata,
      upload_source: file.respond_to?(:tempfile) ? file.tempfile.path : file,
      content_type: file.respond_to?(:content_type) ? file.content_type : nil,
      fields: "id, webViewLink, webContentLink, mimeType"
    )
  end

  private

  def root_folder_id
    Rails.application.credentials.google.root_folder_id
  end
end