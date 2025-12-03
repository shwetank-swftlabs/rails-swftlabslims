class AddChemicalTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :chemical_types do |t|
      t.string :name
      t.boolean :is_active, default: true
      t.string :created_by
      t.timestamps
    end
  end
end
