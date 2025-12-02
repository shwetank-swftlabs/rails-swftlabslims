class AddCompletionDataFieldsToNopProcess < ActiveRecord::Migration[8.1]
  def change
    add_column :nop_processes, :total_reaction_time, :decimal
    add_column :nop_processes, :quenching_water_volume, :decimal
    add_column :nop_processes, :concentrated_effluent_generated_amount, :decimal
    add_column :nop_processes, :concentrated_effluent_generated_ph, :decimal
    add_column :nop_processes, :diluted_effluent_generated_amount, :decimal
    add_column :nop_processes, :diluted_effluent_generated_ph, :decimal
  end
end
