class DataFileParser
  def self.parse(file, file_extension = nil)
    # Determine file extension from file path or use provided extension
    extension = file_extension || File.extname(file.path).delete('.').to_sym
    
    # Roo needs explicit extension for Excel files, especially when tempfile has wrong extension
    options = {}
    if [:xls, :xlsx, :xlsm, :csv].include?(extension)
      options[:extension] = extension
    end
    
    spreadsheet = Roo::Spreadsheet.open(file.path, options)

    results = {}

    spreadsheet.sheets.each do |sheet_name|
      sheet = spreadsheet.sheet(sheet_name)

      begin
        header_row_index, raw_headers = detect_header_row(sheet)
      rescue => e
        next # skip sheets that don’t contain useful headers
      end

      headers = raw_headers.map { |h| normalize_header(h) }

      rows = extract_rows(sheet, header_row_index + 1, headers)

      results[sheet_name] = {
        "headers" => headers,
        "rows"    => rows
      }
    end

    results
  end

  # -----------------------
  # Detect header row
  # -----------------------
  def self.detect_header_row(sheet)
    # Look at first 20 rows or until sheet ends
    (1..[sheet.last_row, 20].min).each do |i|
      row = sheet.row(i)
      return [i, row] if header_like?(row)
    end

    raise "Could not detect header row"
  end

  def self.header_like?(row)
    cells = row.compact
    return false if cells.empty?

    text_cells = cells.select { |c| c.is_a?(String) && c.strip.length > 0 }
    text_cells.length.to_f / cells.length >= 0.5
  end

  # -----------------------
  # Normalize header names
  # -----------------------
  def self.normalize_header(h)
    h.to_s.downcase.strip.gsub(/\s+/, "_").gsub(/[^\w]/, "")
  end

  # -----------------------
  # Extract data rows
  # -----------------------
  def self.extract_rows(sheet, start_row, headers)
    (start_row..sheet.last_row).map do |i|
      row = sheet.row(i)

      next if row.compact.empty?   # skip blank rows

      # Pad missing cells
      row = row + [nil] * (headers.length - row.length)

      headers.zip(row).to_h
    end.compact
  end
end
