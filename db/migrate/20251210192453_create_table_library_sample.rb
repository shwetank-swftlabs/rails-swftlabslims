class CreateTableLibrarySample < ActiveRecord::Migration[8.1]
  def change
    create_table :library_samples do |t|
      t.string :name
      t.string :amount
      t.string :location
      t.boolean :is_active, default: true
      t.string :created_by, default: "system"
      t.references :library_sampleable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
