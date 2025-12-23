module Inventory
  class LibrarySample < ApplicationRecord
    include DefaultDescOrder
    default_desc :created_at

    include QrLabelable
    include Commentable

    belongs_to :library_sampleable, polymorphic: true, optional: true

    validates :amount, presence: true
    validates :unit, presence: true
    validates :name, presence: true
    validates :location, presence: true

    # Scope to filter by parent name (scalable - automatically includes all LibrarySampleable models)
    scope :filtered_by_parent_name, ->(search_term) {
      return all if search_term.blank?

      # Find all parent types that include LibrarySampleable
      parent_types = discover_library_sampleable_types
      return all if parent_types.empty?

      # Build OR conditions for each parent type using proper SQL sanitization
      or_parts = parent_types.filter_map do |parent_type|
        table_name = parent_type.table_name
        matching_ids = parent_type.where("#{table_name}.name ILIKE ?", "%#{search_term}%").pluck(:id)
        
        next nil if matching_ids.empty?
        
        # Build safe SQL condition using connection.quote
        type_quoted = connection.quote(parent_type.name)
        ids_quoted = matching_ids.map { |id| connection.quote(id) }.join(',')
        "(library_sampleable_type = #{type_quoted} AND library_sampleable_id IN (#{ids_quoted}))"
      end

      return none if or_parts.empty?

      # Combine all conditions with OR
      where(or_parts.join(" OR "))
    }

    def default_label_title
      "LIBRARY SAMPLE"
    end

    def default_label_text
      [
        "Resource: #{self.library_sampleable.present? ? self.library_sampleable.name : "N/A"}",
        "Sample Name: #{name}",
      ]
    end

    private

    # Dynamically discover all models that include LibrarySampleable
    def self.discover_library_sampleable_types
      @library_sampleable_types ||= begin
        # Find all models that include the LibrarySampleable concern
        Rails.application.eager_load! if Rails.env.development?
        
        ApplicationRecord.descendants.select do |klass|
          klass.included_modules.include?(LibrarySampleable)
        end
      end
    end
  end
end