module Inventory
  module LibrarySamples
    class Query
      def initialize(params)
        @params = params
      end

      def call
        scope = Inventory::LibrarySample.all
        scope = by_name(scope)
        scope = by_location(scope)
        scope = by_active(scope)
        scope = by_parent_name(scope)
        scope
      end

      private

      attr_reader :params

      def by_name(scope)
        return scope unless params[:q].present?
        scope.where("name ILIKE ?", "%#{params[:q]}%")
      end

      def by_location(scope)
        return scope unless params[:location].present?
        scope.where("location ILIKE ?", "%#{params[:location]}%")
      end

      def by_active(scope)
        case params[:is_active]
        when "true"
          scope.where(is_active: true)
        when "false"
          scope.where(is_active: false)
        when ""
          scope # "All"
        else
          scope.where(is_active: true)
        end
      end

      def by_parent_name(scope)
        return scope unless params[:parent_name].present?

        cake_ids = Products::Cake
          .where("name ILIKE ?", "%#{params[:parent_name]}%")
          .select(:id)

        scope.where(
          library_sampleable_type: "Products::Cake",
          library_sampleable_id: cake_ids
        )
      end
    end
  end
end
