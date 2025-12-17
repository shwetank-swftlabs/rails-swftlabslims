class RenameQncCheckableColumnsToQncCheckRequestable < ActiveRecord::Migration[8.1]
  def change
    # Rename the index first
    rename_index :qnc_checks, :index_qnc_checks_on_qnc_checkable, :index_qnc_checks_on_qnc_check_requestable
    
    # Rename the columns
    rename_column :qnc_checks, :qnc_checkable_id, :qnc_check_requestable_id
    rename_column :qnc_checks, :qnc_checkable_type, :qnc_check_requestable_type
  end
end

