class AddParentChemicalToChemicals < ActiveRecord::Migration[8.1]
  def change
    add_reference :chemicals, :parent_chemical, foreign_key: { to_table: :chemicals }, index: true
  end
end
