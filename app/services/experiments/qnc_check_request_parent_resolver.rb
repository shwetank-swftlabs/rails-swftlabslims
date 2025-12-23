module Experiments
  class QncCheckRequestParentResolver
    PARENTS = {
      cake_id: Products::Cake,
      cnf_id: Products::Cnf
      # future:
      # product_id: Products::Product
      # batch_id: Inventory::Batch
    }.freeze

    def initialize(params)
      @params = params
    end

    def parent
      @parent ||= begin
        # First try nested route params (cake_id, cnf_id)
        key, klass = PARENTS.find { |param_key, _| @params[param_key].present? }
        return klass&.find(@params[key]) if key

        # Fallback to explicit parent_type/parent_id params
        if @params[:parent_type].present? && @params[:parent_id].present?
          @params[:parent_type].constantize.find(@params[:parent_id])
        end
      rescue NameError, ActiveRecord::RecordNotFound
        nil
      end
    end
  end
end

