class CreateImages < ActiveRecord::Migration[8.1]
  def change
    create_table :images do |t|
      t.string :drive_file_id, null: false
      t.string :drive_file_url
      t.string :mime_type
      t.references :attachable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
