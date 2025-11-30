class CreateUsages < ActiveRecord::Migration[8.1]
  def change
    create_table :usages do |t|
      t.references :resource, polymorphic: true, null: false
      t.decimal :amount, null: false
      t.string :purpose, null: false
      t.string :created_by, null: false, default: "system"
      t.timestamps
    end
  end
end
