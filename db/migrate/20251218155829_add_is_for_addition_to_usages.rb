class AddIsForAdditionToUsages < ActiveRecord::Migration[8.1]
  def change
    add_column :usages, :is_for_addition, :boolean, default: false
  end
end
