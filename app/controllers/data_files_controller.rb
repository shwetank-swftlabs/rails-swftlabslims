require "open-uri"

class DataFilesController < ApplicationController
  def create
    @attachable = find_attachable

    uploaded_file = params[:file]
    label = params[:label]
    data_type = params[:data_type]

    if uploaded_file.blank?
      return redirect_to_attachable(alert: "No file selected.")
    end

    if data_type.blank?
      return redirect_to_attachable(alert: "Data type is required.")
    end

    unless valid_file_type?(uploaded_file)
      return redirect_to_attachable(alert: "Only CSV and Excel files (.csv, .xls, .xlsx, .xlsm) are allowed.")
    end

    begin
      upload_result = GoogleDriveService.new.upload(uploaded_file)

      data_file = @attachable.data_files.create!(
        file_name: uploaded_file.original_filename,
        drive_file_id: upload_result.id,
        drive_file_url: upload_result.web_view_link,
        mime_type: upload_result.mime_type,
        data_type: data_type,
        created_by: current_user.email,
        label: label
      )
      
      parse_and_store_data(data_file)

      redirect_to_attachable(notice: "Data file uploaded successfully.")

    rescue => e
      Rails.logger.error("Data file upload failed: #{e.message}")
      return redirect_to_attachable(alert: "Data file upload failed. Please try again.")
    end
  end

  def show
    @attachable = find_attachable
    @data_file = @attachable.data_files.find(params[:id])
    
    respond_to do |format|
      format.html { render partial: "shared/sidebar_layout/view_file_data_modal_content", locals: { data_file: @data_file }, layout: false }
      format.json { render json: { parsed_data: @data_file.parsed_data } }
    end
  end

  private

  def parse_and_store_data(data_file)
    # 1. Download file from Google Drive into a Tempfile with correct extension
    # Roo needs the correct extension to properly detect Excel file types
    file_extension = File.extname(data_file.file_name).presence || ".bin"
    tempfile = GoogleDriveService.new.download_to_tempfile(data_file.drive_file_id, file_extension)

    # 2. Parse the file (your parser) - pass extension explicitly for better Excel support
    extension_symbol = file_extension.delete('.').downcase.to_sym
    # Only pass extension if it's a valid type, otherwise let Roo auto-detect
    extension_symbol = nil unless [:xls, :xlsx, :xlsm, :csv].include?(extension_symbol)
    parsed = DataFileParser.parse(tempfile, extension_symbol)

    # 3. Store parsed data (simple JSON storage)
    data_file.update!(parsed_data: parsed)

  rescue => e
    Rails.logger.error("Data file parsing failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise "Failed to parse data file: #{e.message}"
  ensure
    tempfile&.close!
    tempfile&.unlink
  end

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
  
    raise "Attachable not found"
  end

  def redirect_to_attachable(flash_hash = {})
    redirect_to polymorphic_url(@attachable, { tab: :data_files }), flash: flash_hash
  end

  def valid_file_type?(file)
    return false if file.blank?

    filename = file.original_filename.to_s.downcase
    allowed_extensions = ['.csv', '.xls', '.xlsx', '.xlsm']
    
    allowed_extensions.any? { |ext| filename.end_with?(ext) }
  end
end
