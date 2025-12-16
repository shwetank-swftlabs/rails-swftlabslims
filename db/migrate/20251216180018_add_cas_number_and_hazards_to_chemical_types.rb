class AddCasNumberAndHazardsToChemicalTypes < ActiveRecord::Migration[8.1]
  def change
    add_column :chemical_types, :cas_number, :string
    add_column :chemical_types, :hazards, :string
  end
end
