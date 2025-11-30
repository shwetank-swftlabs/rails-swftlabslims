class CreateFeedstocks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedstocks do |t|
      t.string :name, null: false
      t.string :feedstock_type, null: false
      t.string :supplier, null: false
      t.decimal :quantity, null: false
      t.string :unit, null: false
      t.string :location
      t.boolean :is_active, null: false, default: true
      t.string :created_by, null: false, default: "system"
      t.timestamps
    end
  end
end
