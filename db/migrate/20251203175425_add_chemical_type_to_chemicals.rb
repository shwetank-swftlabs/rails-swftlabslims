class AddChemicalTypeToChemicals < ActiveRecord::Migration[8.1]
  def change
    remove_column :chemicals, :chemical_type, :string
    remove_column :chemicals, :location_details, :string
    add_reference :chemicals, :chemical_type, null: false, foreign_key: true
  end
end
