module Experiments
  module QncChecks
    class Query
      def initialize(params)
        @params = params
      end

      def call
        scope = Experiments::QncCheckRequest.all
        scope = by_name(scope)
        scope = by_resource_name(scope)
        scope = by_assigned_to(scope)
        scope = by_requested_by(scope)
        scope = by_active(scope)
        scope
      end

      private

      attr_reader :params

      def by_name(scope)
        return scope unless params[:q].present?
        scope.where("name ILIKE ?", "%#{params[:q]}%")
      end

      def by_resource_name(scope)
        return scope unless params[:resource_name].present?

        # Search across all polymorphic parent types
        # For now, we'll search in Products::Cake, but this can be extended
        cake_ids = Products::Cake
          .where("name ILIKE ?", "%#{params[:resource_name]}%")
          .select(:id)

        scope.where(
          qnc_check_requestable_type: "Products::Cake",
          qnc_check_requestable_id: cake_ids
        )
      end

      def by_assigned_to(scope)
        return scope unless params[:assigned_to].present?
        scope.where("requested_from ILIKE ?", "%#{params[:assigned_to]}%")
      end

      def by_requested_by(scope)
        return scope unless params[:requested_by].present?
        scope.where("requested_by ILIKE ?", "%#{params[:requested_by]}%")
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
          scope # Default to all (no filter)
        end
      end
    end
  end
end

