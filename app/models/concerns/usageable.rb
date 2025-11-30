module Usageable
  extend ActiveSupport::Concern

  included do
    has_many :usages, -> { order(updated_at: :desc) }, as: :resource, dependent: :destroy
  end

  # Calculate the remaining amount after all usages
  # Override quantity_field_name if your resource uses a different field name
  def remaining_amount
    initial_quantity - total_used_amount
  end


    # Check if there's any remaining amount
  def has_remaining?
    remaining_amount > 0
  end

  #private
  # Get the total amount used across all usages
  def total_used_amount
    usages.sum(:amount) || 0
  end

  # Get the initial quantity
  # Override this method if your resource uses a different field name than 'quantity'
  def initial_quantity
    respond_to?(:quantity) ? quantity : 0
  end
end

