class ProductsController < ApplicationController
  def index
    add_breadcrumb "Products", products_path
  end
end