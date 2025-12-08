class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  AMOUNT_UNITS = {
    "ml" => "mL (Milliliters)",
    "litres" => "L (Litres)",
    "grams" => "g (Grams)",
    "kg" => "kg (Kilograms)",
    "pounds" => "lb (Pounds)",
    "other" => "Other"
  }.freeze

  def google_drive_folder_url
    return nil unless has_attribute?(:google_drive_folder_id) && google_drive_folder_id.present?
    "https://drive.google.com/drive/folders/#{google_drive_folder_id}"
  end
end
