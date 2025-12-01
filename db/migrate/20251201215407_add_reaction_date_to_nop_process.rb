class AddReactionDateToNopProcess < ActiveRecord::Migration[8.1]
  def change
    add_column :nop_processes, :nop_reaction_date, :date, null: false
  end
end
