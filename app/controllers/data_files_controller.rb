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

      return redirect_to_polymorphic_parent(@attachable, tab: :data_files, flash_hash: { notice: "Data file uploaded successfully." })

    rescue => e
      Rails.logger.error("Data file upload failed: #{e.message}")
      return redirect_to_polymorphic_parent(@attachable, tab: :data_files, flash_hash: { alert: "Data file upload failed. Please try again." })
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
    return if data_file.mime_type == 'application/pdf' # PDFs are not parsed

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

  def valid_file_type?(file)
    return false if file.blank?

    filename = file.original_filename.to_s.downcase
    allowed_extensions = ['.csv', '.xls', '.xlsx', '.xlsm', '.pdf']
    
    allowed_extensions.any? { |ext| filename.end_with?(ext) }
  end
end
