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
end
