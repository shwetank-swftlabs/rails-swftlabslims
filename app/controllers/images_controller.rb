require "open-uri"

class ImagesController < ApplicationController
  # skip_forgery_protection only: :show

  def show
    image = Image.find(params[:id])

    # Download full binary file from Google Drive (authenticated)
    data = Rails.cache.fetch("drive-image-#{image.id}", expires_in: 24.hours) do
      GoogleDriveService.new.download(image.drive_file_id)
    end
  
    # Serve as real image bytes
    send_data data,
      type: image.mime_type || "image/jpeg",
      disposition: "inline"
  end

  def create
    @attachable = find_polymorphic_parent

    uploaded_file = params[:file]
    label = params[:label]

    if uploaded_file.blank?
      return redirect_to_attachable(alert: "No file selected.")
    end

    begin
      folder_id = @attachable.default_upload_folder_id
      upload_result = GoogleDriveService.new.upload(uploaded_file, folder_id)

      @attachable.images.create!(
        name: uploaded_file.original_filename,
        drive_file_id: upload_result.id,
        drive_file_url: upload_result.web_view_link,
        mime_type: upload_result.mime_type,
        created_by: current_user.email,
        label: label
      )

      redirect_to_polymorphic_parent(@attachable, tab: :images, flash_hash: { notice: "Image uploaded successfully." })

    rescue => e
      Rails.logger.error("Image upload failed: #{e.message}")
      return redirect_to_polymorphic_parent(@attachable, tab: :images, flash_hash: { alert: "Image upload failed. Please try again." })
    end
  end
end
