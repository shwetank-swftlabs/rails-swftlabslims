class RemoveFeedstockTypeFromFeedstocks < ActiveRecord::Migration[8.1]
  def change
    remove_column :feedstocks, :feedstock_type, :string
    change_column_null :feedstocks, :supplier, false
    change_column_null :feedstocks, :location, false
    add_reference :feedstocks, :feedstock_type, null: false, foreign_key: true
  end
end
