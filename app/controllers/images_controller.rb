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
    @attachable = find_attachable

    uploaded_file = params[:file]
    label = params[:label]

    if uploaded_file.blank?
      return redirect_to_attachable(alert: "No file selected.")
    end

    begin
      upload_result = GoogleDriveService.new.upload(uploaded_file)

      @attachable.images.create!(
        name: uploaded_file.original_filename,
        drive_file_id: upload_result.id,
        drive_file_url: upload_result.web_view_link,
        mime_type: upload_result.mime_type,
        label: label
      )

      redirect_to_attachable(notice: "Image uploaded successfully.")

    rescue => e
      Rails.logger.error("Image upload failed: #{e.message}")
      return redirect_to_attachable(alert: "Image upload failed. Please try again.")
    end
  end

  private

  def find_attachable
    params.each do |key, value|
      next unless key.to_s =~ /(.+)_id$/
  
      basename = $1.classify  # "Equipment"
  
      # Try top-level first (User, Product, etc.)
      klass = basename.safe_constantize
  
      # Try namespaced versions (e.g., Inventory::Equipment)
      if klass.nil?
        # Search loaded constants for matches ending in ::Equipment
        klass = ObjectSpace.each_object(Class).find do |c|
          c.name&.end_with?("::#{basename}")
        end
      end
  
      # If we found it, load the record
      return klass.find(value) if klass
    end
  
    rdef find_attachable
    params.each do |key, value|
      next unless key.to_s =~ /(.+)_id$/
  
      basename = $1.classify  # "Equipment"
  
      # Try top-level first (User, Product, etc.)
      klass = basename.safe_constantize
  
      # Try namespaced versions (e.g., Inventory::Equipment)
      if klass.nil?
        # Search loaded constants for matches ending in ::Equipment
        klass = ObjectSpace.each_object(Class).find do |c|
          c.name&.end_with?("::#{basename}")
        end
      end
  
      # If we found it, load the record
      return klass.find(value) if klass
    end
  
    raise "Attachable not found"
  end
  

  def redirect_to_attachable(flash_hash = {})
    redirect_to polymorphic_url(@attachable, { tab: :images }), flash: flash_hash
  end

  def direct_download_url(id)
    "https://drive.google.com/uc?export=view&id=#{id}"
  end
end
