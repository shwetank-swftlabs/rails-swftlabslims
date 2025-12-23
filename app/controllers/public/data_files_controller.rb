class Public::DataFilesController < ApplicationController
  skip_before_action :require_login

  def show
    @data_file = DataFile.find_by(public_token: params[:token])

    unless @data_file
      render plain: "File not found", status: :not_found
      return
    end

    unless @data_file.is_public? && @data_file.pdf?
      render plain: "File is not publicly accessible", status: :forbidden
      return
    end

    # Download file from Google Drive (cached)
    data = Rails.cache.fetch("public-data-file-#{@data_file.id}", expires_in: 24.hours) do
      GoogleDriveService.new.download(@data_file.drive_file_id)
    end

    # Serve as PDF with proper headers
    send_data data,
      type: @data_file.mime_type || "application/pdf",
      disposition: "inline",
      filename: @data_file.file_name
  rescue => e
    Rails.logger.error("Failed to serve public data file: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render plain: "Error serving file", status: :internal_server_error
  end
end

