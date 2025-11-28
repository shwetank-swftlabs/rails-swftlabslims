class AddCreatedByToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :created_by, :string, default: "system", null: false
  end
end
