class InventoryController < ApplicationController
  def index
    add_breadcrumb "Inventory", inventory_path
  end
end