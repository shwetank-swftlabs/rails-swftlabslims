class CreateDataFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :data_files do |t|
      t.string :data_type, null: false
      t.string :label
      t.string :file_name, null: false
      t.string :mime_type, null: false
      t.string :drive_file_id, null: false
      t.string :drive_file_url, null: false
      t.jsonb :parsed_data
      t.references :attachable, polymorphic: true, null: false
      t.string :created_by, null: false, default: "system"
      t.timestamps
    end
  end
end
