class AddEquipmentIdToNopProcess < ActiveRecord::Migration[8.1]
  def change
    add_reference :nop_processes, :reactor, null: false, foreign_key: { to_table: :equipments }
  end
end
