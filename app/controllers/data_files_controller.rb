require "open-uri"

class DataFilesController < ApplicationController
  def create
    @attachable = find_polymorphic_parent

    uploaded_file = params[:file]
    label = params[:label]
    data_type = params[:data_type]

    if uploaded_file.blank?
      return redirect_to_polymorphic_parent(@attachable, tab: :data_files, flash_hash: { alert: "No file selected." })
    end

    if data_type.blank?
      return redirect_to_polymorphic_parent(@attachable, tab: :data_files, flash_hash: { alert: "Data type is required." })
    end

    unless valid_file_type?(uploaded_file)
      return redirect_to_polymorphic_parent(@attachable, tab: :data_files, flash_hash: { alert: "Only CSV, Excel files (.csv, .xls, .xlsx, .xlsm), and PDF files (.pdf) are allowed." })
    end

    begin
      folder_id = @attachable.default_upload_folder_id
      root_folder_id = Rails.application.credentials.google.root_folder_id
      
      # Log upload details
      Rails.logger.info "=" * 80
      Rails.logger.info "DATA FILE UPLOAD DETAILS"
      Rails.logger.info "=" * 80
      Rails.logger.info "File Name: #{uploaded_file.original_filename}"
      Rails.logger.info "Attachable Type: #{@attachable.class.name}"
      Rails.logger.info "Attachable ID: #{@attachable.id}"
      Rails.logger.info "Attachable Name: #{@attachable.try(:name) || @attachable.try(:code) || 'N/A'}"
      Rails.logger.info "Folder ID from default_upload_folder_id: #{folder_id.inspect}"
      Rails.logger.info "Root Folder ID from credentials: #{root_folder_id.inspect}"
      Rails.logger.info "Final Folder ID being used: #{folder_id || root_folder_id}"
      Rails.logger.info "Folder URL: https://drive.google.com/drive/folders/#{folder_id || root_folder_id}"
      Rails.logger.info "-" * 80
      
      upload_result = GoogleDriveService.new.upload(uploaded_file, folder_id)
      
      Rails.logger.info "Upload Result:"
      Rails.logger.info "  File ID: #{upload_result.id}"
      Rails.logger.info "  Web View Link: #{upload_result.web_view_link}"
      Rails.logger.info "  MIME Type: #{upload_result.mime_type}"
      Rails.logger.info "=" * 80

      data_file = @attachable.data_files.create!(
        file_name: uploaded_file.original_filename,
        drive_file_id: upload_result.id,
        drive_file_url: upload_result.web_view_link,
        mime_type: upload_result.mime_type,
        data_type: data_type,
        created_by: current_user.email,
        label: label
      )
      
      Rails.logger.info "Data File Created: ID=#{data_file.id}"
      Rails.logger.info "=" * 80
      
      parse_and_store_data(data_file)

      return redirect_to_polymorphic_parent(@attachable, tab: :data_files, flash_hash: { notice: "Data file uploaded successfully." })

    rescue => e
      Rails.logger.error("Data file upload/parsing failed: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      error_message = e.message.include?("parse") ? "File uploaded but parsing failed: #{e.message}" : "Data file upload failed: #{e.message}"
      return redirect_to_polymorphic_parent(@attachable, tab: :data_files, flash_hash: { alert: error_message })
    end
  end

  def show
    @attachable = find_polymorphic_parent
    @data_file = @attachable.data_files.find(params[:id])
    
    respond_to do |format|
      format.html { render partial: "shared/sidebar_layout/view_file_data_modal_content", locals: { data_file: @data_file }, layout: false }
      format.json { render json: { parsed_data: @data_file.parsed_data } }
    end
  end

  private

  def parse_and_store_data(data_file)
    # PDFs are not parsed - check both MIME type and file extension
    return if data_file.mime_type == 'application/pdf' || data_file.file_name.downcase.end_with?('.pdf')

    # 1. Download file from Google Drive into a Tempfile with correct extension
    # Roo needs the correct extension to properly detect Excel file types
    file_extension = File.extname(data_file.file_name).presence || ".bin"
    tempfile = GoogleDriveService.new.download_to_tempfile(data_file.drive_file_id, file_extension)

    # 2. Parse the file (your parser) - pass extension explicitly for better Excel support
    extension_symbol = file_extension.delete('.').downcase.to_sym
    # Only pass extension if it's a valid type, otherwise let Roo auto-detect
    extension_symbol = nil unless [:xls, :xlsx, :xlsm, :csv].include?(extension_symbol)
    
    Rails.logger.info("Parsing file: #{data_file.file_name}, extension: #{extension_symbol}")
    parsed = DataFileParser.parse(tempfile, extension_symbol)
    Rails.logger.info("Parsed data keys: #{parsed.keys.inspect}")

    # 3. Store parsed data (simple JSON storage)
    if parsed.present? && parsed.is_a?(Hash)
      data_file.update!(parsed_data: parsed)
      Rails.logger.info("Successfully stored parsed data for file: #{data_file.file_name}")
    else
      Rails.logger.warn("Parsed data is empty or invalid for file: #{data_file.file_name}")
      raise "No data found in file or parsing returned invalid format"
    end

  rescue => e
    Rails.logger.error("Data file parsing failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise "Failed to parse data file: #{e.message}"
  ensure
    tempfile&.close!
    tempfile&.unlink
  end

  def valid_file_type?(file)
    return false if file.blank?

    filename = file.original_filename.to_s.downcase
    allowed_extensions = ['.csv', '.xls', '.xlsx', '.xlsm', '.pdf']
    
    allowed_extensions.any? { |ext| filename.end_with?(ext) }
  end
end
