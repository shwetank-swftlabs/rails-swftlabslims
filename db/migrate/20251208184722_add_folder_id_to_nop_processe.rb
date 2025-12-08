class AddFolderIdToNopProcesse < ActiveRecord::Migration[8.1]
  def change
    add_column :nop_processes, :google_drive_folder_id, :string
  end
end
