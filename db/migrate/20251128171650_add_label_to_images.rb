class AddLabelToImages < ActiveRecord::Migration[8.1]
  def change
    add_column :images, :label, :string
  end
end
