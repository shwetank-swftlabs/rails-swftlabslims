# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_03_175425) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cakes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.decimal "moisture_percentage", null: false
    t.string "name", null: false
    t.bigint "nop_process_id"
    t.decimal "ph", null: false
    t.decimal "quantity", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["nop_process_id"], name: "index_cakes_on_nop_process_id"
  end

  create_table "chemical_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by"
    t.boolean "is_active", default: true
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "chemicals", force: :cascade do |t|
    t.bigint "chemical_type_id", null: false
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.date "expiry_date"
    t.boolean "is_active", default: true, null: false
    t.string "location"
    t.string "name", null: false
    t.decimal "quantity", null: false
    t.string "supplier"
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["chemical_type_id"], name: "index_chemicals_on_chemical_type_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "commentable_id", null: false
    t.string "commentable_type", null: false
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
  end

  create_table "data_files", force: :cascade do |t|
    t.bigint "attachable_id", null: false
    t.string "attachable_type", null: false
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.string "data_type", null: false
    t.string "drive_file_id", null: false
    t.string "drive_file_url", null: false
    t.string "file_name", null: false
    t.string "label"
    t.string "mime_type", null: false
    t.jsonb "parsed_data"
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_data_files_on_attachable"
  end

  create_table "equipment_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "equipments", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "created_by", null: false
    t.bigint "equipment_type_id"
    t.boolean "is_active", default: true
    t.string "location"
    t.string "name", null: false
    t.string "supplier"
    t.datetime "updated_at", null: false
    t.index ["equipment_type_id"], name: "index_equipments_on_equipment_type_id"
  end

  create_table "feedstocks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.string "feedstock_type", null: false
    t.boolean "is_active", default: true, null: false
    t.string "location"
    t.string "name", null: false
    t.decimal "quantity", null: false
    t.string "supplier", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.bigint "attachable_id", null: false
    t.string "attachable_type", null: false
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.string "drive_file_id", null: false
    t.string "drive_file_url"
    t.string "label"
    t.string "mime_type"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_images_on_attachable"
  end

  create_table "nop_processes", force: :cascade do |t|
    t.decimal "additional_nitric_acid_amount"
    t.decimal "additional_nitric_acid_molarity"
    t.string "batch_number", null: false
    t.decimal "concentrated_effluent_generated_amount"
    t.decimal "concentrated_effluent_generated_ph"
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.decimal "diluted_effluent_generated_amount"
    t.decimal "diluted_effluent_generated_ph"
    t.decimal "feedstock_amount", null: false
    t.string "feedstock_moisture_percentage", null: false
    t.string "feedstock_type", null: false
    t.string "feedstock_unit", null: false
    t.decimal "final_nitric_acid_amount", null: false
    t.decimal "final_nitric_acid_molarity", null: false
    t.string "nitric_acid_units", null: false
    t.date "nop_reaction_date", null: false
    t.bigint "previous_process_id"
    t.decimal "quenching_water_volume"
    t.string "reaction_type"
    t.bigint "reactor_id", null: false
    t.decimal "rotation_rate", null: false
    t.decimal "total_reaction_time"
    t.datetime "updated_at", null: false
    t.index ["previous_process_id"], name: "index_nop_processes_on_previous_process_id"
    t.index ["reactor_id"], name: "index_nop_processes_on_reactor_id"
  end

  create_table "usages", force: :cascade do |t|
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.string "created_by", default: "system", null: false
    t.string "purpose", null: false
    t.bigint "resource_id", null: false
    t.string "resource_type", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_usages_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cakes", "nop_processes"
  add_foreign_key "chemicals", "chemical_types"
  add_foreign_key "equipments", "equipment_types"
  add_foreign_key "nop_processes", "equipments", column: "reactor_id"
  add_foreign_key "nop_processes", "nop_processes", column: "previous_process_id"
end
