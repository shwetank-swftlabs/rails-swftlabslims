class MakePublicOptionToDataFiles < ActiveRecord::Migration[8.1]
  def change
    add_column :data_files, :is_public, :boolean, default: false, null: false
    add_column :data_files, :public_token, :string

    add_index :data_files, :public_token, unique: true
  end
end
