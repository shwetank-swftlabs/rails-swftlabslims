module Products
  class BaseProductsController < ApplicationController
    before_action :set_products_breadcrumbs_root

    private

    def set_products_breadcrumbs_root
      add_breadcrumb "Products", products_path
    end
  end
end