class AddCakes < ActiveRecord::Migration[8.1]
  def change
    create_table :cakes do |t|
      t.string :name, null: false
      t.decimal :quantity, null: false
      t.string :unit, null: false
      t.decimal :moisture_percentage, null: false
      t.decimal :ph, null: false
      t.string :created_by, null: false, default: "system"
      t.references :nop_process, foreign_key: true
      t.timestamps
    end
  end
end
