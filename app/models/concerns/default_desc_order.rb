# app/models/concerns/default_desc_order.rb
module DefaultDescOrder
  extend ActiveSupport::Concern

  class_methods do
    def default_desc(column = :id)
      default_scope { order(column => :desc) }
    end
  end
end

