class AddProductSubstrates < ActiveRecord::Migration[8.1]
  def change
    create_table :substrates do |t|
      t.string :name
      t.string :substrate_type
      t.decimal :quantity
      t.string :unit
      t.string :tray_description
      t.string :location
      t.boolean :is_active, default: true
      t.string :created_by, default: "system"
      t.timestamps

      t.references :cnf, foreign_key: true, null: true
    end
  end
end
