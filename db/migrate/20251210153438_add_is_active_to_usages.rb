class AddIsActiveToUsages < ActiveRecord::Migration[8.1]
  def change
    add_column :usages, :is_active, :boolean, default: true
  end
end
