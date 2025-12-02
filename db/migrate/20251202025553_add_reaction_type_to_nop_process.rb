class AddReactionTypeToNopProcess < ActiveRecord::Migration[8.1]
  def change
    add_column :nop_processes, :reaction_type, :string
  end
end
