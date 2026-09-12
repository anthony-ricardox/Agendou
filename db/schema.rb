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

ActiveRecord::Schema[8.1].define(version: 2026_09_12_170648) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.datetime "reminder_sent_at"
    t.bigint "service_id", null: false
    t.datetime "starts_at"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["service_id"], name: "index_appointments_on_service_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.time "end_time"
    t.bigint "provider_id", null: false
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_availabilities_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_providers_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_minutes"
    t.string "name"
    t.decimal "price"
    t.bigint "provider_id", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_services_on_provider_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "appointments", "services"
  add_foreign_key "appointments", "users"
  add_foreign_key "availabilities", "providers"
  add_foreign_key "providers", "users"
  add_foreign_key "services", "providers"
end
