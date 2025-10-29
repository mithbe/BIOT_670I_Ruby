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

ActiveRecord::Schema[8.0].define(version: 2025_10_01_043137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "dandelions", force: :cascade do |t|
    t.string "species"
    t.string "location"
    t.datetime "collected_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "search_vector"
    t.index ["search_vector"], name: "index_dandelions_on_search_vector", using: :gin
    t.index ["user_id"], name: "index_dandelions_on_user_id"
  end

  create_table "dandelions_userinfos", id: false, force: :cascade do |t|
    t.bigint "userinfo_id", null: false
    t.bigint "dandelion_id", null: false
  end

  create_table "file_records", force: :cascade do |t|
    t.string "name"
    t.string "original_name"
    t.string "file_type"
    t.string "mime_type"
    t.bigint "size"
    t.text "description"
    t.jsonb "tags"
    t.string "storage_path"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["metadata"], name: "index_file_records_on_metadata", using: :gin
    t.index ["tags"], name: "index_file_records_on_tags", using: :gin
    t.index ["user_id"], name: "index_file_records_on_user_id"
  end

  create_table "file_uploads", force: :cascade do |t|
    t.string "filename"
    t.string "filetype"
    t.bigint "user_id", null: false
    t.bigint "dandelion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dandelion_id"], name: "index_file_uploads_on_dandelion_id"
    t.index ["user_id"], name: "index_file_uploads_on_user_id"
  end

  create_table "metadata", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.bigint "file_upload_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "search_vector"
    t.index ["file_upload_id"], name: "index_metadata_on_file_upload_id"
    t.index ["search_vector"], name: "index_metadata_on_search_vector", using: :gin
  end

  create_table "samples", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_samples_on_user_id"
  end

  create_table "upload_batches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.json "files", default: [], null: false
    t.string "status", default: "uploaded", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_upload_batches_on_user_id"
  end

  create_table "userinfos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.bigint "user_id", null: false
    t.tsvector "search_vector"
    t.index ["search_vector"], name: "index_userinfos_on_search_vector", using: :gin
    t.index ["user_id"], name: "index_userinfos_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "dandelions", "users"
  add_foreign_key "file_records", "users"
  add_foreign_key "file_uploads", "dandelions"
  add_foreign_key "file_uploads", "users"
  add_foreign_key "metadata", "file_uploads"
  add_foreign_key "samples", "users"
  add_foreign_key "upload_batches", "users"
  add_foreign_key "userinfos", "users"
end
