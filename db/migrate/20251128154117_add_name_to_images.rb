class AddNameToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :name, :string, null: false
  end
end
