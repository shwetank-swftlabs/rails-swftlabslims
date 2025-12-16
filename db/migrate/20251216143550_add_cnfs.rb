class AddCnfs < ActiveRecord::Migration[8.1]
  def change
    create_table :cnfs do |t|
      t.string :name
      t.decimal :quantity
      t.string :unit
      t.string :location
      t.string :created_by
      t.boolean :is_active, default: true
      t.references :cake, foreign_key: true

      t.timestamps
    end
  end
end
