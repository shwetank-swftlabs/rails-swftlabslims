module Inventory
  class LibrarySampleParentResolver
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
        key, klass = PARENTS.find { |param_key, _| @params[param_key].present? }
        klass&.find(@params[key]) if key
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
  end
end

