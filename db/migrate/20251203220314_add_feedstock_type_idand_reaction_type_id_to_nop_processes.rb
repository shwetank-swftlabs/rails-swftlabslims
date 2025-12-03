class AddFeedstockTypeIdandReactionTypeIdToNopProcesses < ActiveRecord::Migration[8.1]
  def change
    remove_column :nop_processes, :feedstock_type, :string
    remove_column :nop_processes, :reaction_type, :string
    add_reference :nop_processes, :feedstock_type, null: false, foreign_key: true
    add_reference :nop_processes, :nop_reaction_type, null: false, foreign_key: true
  end
end
