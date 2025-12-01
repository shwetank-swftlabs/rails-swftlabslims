class AddCreatedByToNopProcess < ActiveRecord::Migration[8.1]
  def change
    add_column :nop_processes, :created_by, :string, null: false, default: "system"
  end
end
