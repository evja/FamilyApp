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

ActiveRecord::Schema[7.1].define(version: 2026_02_02_222823) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme"
  end

  create_table "family_invitations", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "email"
    t.string "token"
    t.string "status"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_invitations_on_family_id"
    t.index ["token"], name: "index_family_invitations_on_token", unique: true
  end

  create_table "family_values", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_values_on_family_id"
  end

  create_table "family_visions", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.text "mission_statement"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ten_year_dream"
    t.index ["family_id"], name: "index_family_visions_on_family_id"
  end

  create_table "issue_assists", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "user_id", null: false
    t.text "original_text"
    t.text "suggested_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id", "created_at"], name: "index_issue_assists_on_family_id_and_created_at"
    t.index ["family_id"], name: "index_issue_assists_on_family_id"
    t.index ["user_id"], name: "index_issue_assists_on_user_id"
  end

  create_table "issue_members", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_issue_members_on_issue_id"
    t.index ["member_id"], name: "index_issue_members_on_member_id"
  end

  create_table "issue_values", force: :cascade do |t|
    t.bigint "issue_id", null: false
    t.bigint "family_value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_value_id"], name: "index_issue_values_on_family_value_id"
    t.index ["issue_id"], name: "index_issue_values_on_issue_id"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "list_type"
    t.text "description"
    t.string "category"
    t.string "urgency"
    t.string "status", default: "new"
    t.string "issue_type"
    t.integer "root_issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "resolved_at"
    t.index ["family_id", "status"], name: "index_issues_on_family_id_and_status"
    t.index ["family_id"], name: "index_issues_on_family_id"
    t.index ["root_issue_id"], name: "index_issues_on_root_issue_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name"
    t.integer "age"
    t.text "personality"
    t.text "interests"
    t.text "health"
    t.text "development"
    t.text "needs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_parent", default: false
    t.bigint "user_id"
    t.index ["family_id"], name: "index_members_on_family_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "family_id"
    t.boolean "admin"
    t.boolean "is_subscribed"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "family_invitations", "families"
  add_foreign_key "family_values", "families"
  add_foreign_key "family_visions", "families"
  add_foreign_key "issue_assists", "families"
  add_foreign_key "issue_assists", "users"
  add_foreign_key "issue_members", "issues"
  add_foreign_key "issue_members", "members"
  add_foreign_key "issue_values", "family_values"
  add_foreign_key "issue_values", "issues"
  add_foreign_key "issues", "families"
  add_foreign_key "members", "families"
  add_foreign_key "members", "users"
  add_foreign_key "users", "families"
end
