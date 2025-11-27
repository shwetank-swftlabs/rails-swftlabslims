module LocationEnum
  extend ActiveSupport::Concern

  included do
    enum :location, {
      lihti: "lihti",
      other_location: "other_location"
    }.freeze
  end
end
