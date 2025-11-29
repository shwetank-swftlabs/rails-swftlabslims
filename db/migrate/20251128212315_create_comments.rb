class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.text :body, null: false
      t.string :created_by, null: false, default: "system"
      t.references :commentable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
