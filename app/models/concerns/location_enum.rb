module LocationEnum
  extend ActiveSupport::Concern

  LOCATIONS = {
    'lihti': 'lihti',
    'other': 'other',
  }.freeze

  included do
    enum location: LOCATIONS
  end
end