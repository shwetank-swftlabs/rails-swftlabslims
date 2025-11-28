module LocationEnum
  extend ActiveSupport::Concern

  GLOBAL_LOCATION_VALUES = {
    lihti: "lihti",
    nfc: "nfc",
    other_location: "other_location"
  }.freeze

  class_methods do
    def uses_location_enum_for(attribute_name)
      enum attribute_name, GLOBAL_LOCATION_VALUES
    end
  end
end
