class AddFeedstockTypesAndNopReactionTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :feedstock_types do |t|
      t.string :name
      t.boolean :is_active, default: true
      t.string :created_by, default: "system"
      t.timestamps
    end

    create_table :nop_reaction_types do |t|
      t.string :name
      t.boolean :is_active, default: true
      t.string :created_by, default: "system"
      t.timestamps
    end
  end
end
