class AddUnitsForLibrarySamples < ActiveRecord::Migration[8.1]
  def change
    add_column :library_samples, :unit, :string
  end
end
