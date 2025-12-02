class AddPreviousProcessToNopProcess < ActiveRecord::Migration[8.1]
  def change
    add_reference :nop_processes, :previous_process, foreign_key: { to_table: :nop_processes }
  end
end
