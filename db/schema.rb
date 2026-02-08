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

ActiveRecord::Schema[7.1].define(version: 2026_02_08_053549) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agenda_items", force: :cascade do |t|
    t.bigint "rhythm_id", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.integer "duration_minutes"
    t.text "instructions"
    t.string "link_type", default: "none"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rhythm_id", "position"], name: "index_agenda_items_on_rhythm_id_and_position"
    t.index ["rhythm_id"], name: "index_agenda_items_on_rhythm_id"
  end

  create_table "completion_items", force: :cascade do |t|
    t.bigint "rhythm_completion_id", null: false
    t.bigint "agenda_item_id", null: false
    t.boolean "checked", default: false
    t.datetime "checked_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agenda_item_id"], name: "index_completion_items_on_agenda_item_id"
    t.index ["rhythm_completion_id", "agenda_item_id"], name: "index_completion_items_on_completion_and_agenda", unique: true
    t.index ["rhythm_completion_id"], name: "index_completion_items_on_rhythm_completion_id"
  end

  create_table "families", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "theme"
    t.string "subscription_status", default: "free"
    t.string "stripe_subscription_id"
    t.index ["subscription_status"], name: "index_families_on_subscription_status"
  end

  create_table "family_invitations", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "email"
    t.string "token"
    t.string "status"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "member_id"
    t.index ["family_id"], name: "index_family_invitations_on_family_id"
    t.index ["member_id"], name: "index_family_invitations_on_member_id"
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
    t.string "role", default: "child", null: false
    t.string "email"
    t.datetime "invited_at"
    t.datetime "joined_at"
    t.date "birthdate"
    t.string "theme_color"
    t.string "nickname"
    t.text "bio"
    t.string "avatar_emoji"
    t.text "strengths"
    t.text "growth_areas"
    t.index ["email"], name: "index_members_on_email"
    t.index ["family_id", "role"], name: "index_members_on_family_id_and_role"
    t.index ["family_id"], name: "index_members_on_family_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "relationship_assessments", force: :cascade do |t|
    t.bigint "relationship_id", null: false
    t.bigint "assessor_id"
    t.bigint "rhythm_completion_id"
    t.date "assessed_on", null: false
    t.string "quarter_key"
    t.integer "score_cooperation", null: false
    t.integer "score_affection", null: false
    t.integer "score_trust", null: false
    t.integer "total_score"
    t.text "whats_working"
    t.text "whats_not_working"
    t.text "action_items"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessor_id"], name: "index_relationship_assessments_on_assessor_id"
    t.index ["relationship_id", "assessed_on"], name: "idx_on_relationship_id_assessed_on_df40e7afe4"
    t.index ["relationship_id", "quarter_key"], name: "idx_on_relationship_id_quarter_key_74dd2bb0f6"
    t.index ["relationship_id"], name: "index_relationship_assessments_on_relationship_id"
    t.index ["rhythm_completion_id"], name: "index_relationship_assessments_on_rhythm_completion_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.bigint "member_low_id", null: false
    t.bigint "member_high_id", null: false
    t.string "relationship_type"
    t.integer "current_health_score"
    t.string "current_health_band"
    t.datetime "last_assessed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_health_band"], name: "index_relationships_on_current_health_band"
    t.index ["family_id", "member_low_id", "member_high_id"], name: "idx_relationships_unique_pair", unique: true
    t.index ["family_id"], name: "index_relationships_on_family_id"
    t.index ["member_high_id"], name: "index_relationships_on_member_high_id"
    t.index ["member_low_id"], name: "index_relationships_on_member_low_id"
  end

  create_table "rhythm_completions", force: :cascade do |t|
    t.bigint "rhythm_id", null: false
    t.bigint "completed_by_id"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "notes"
    t.string "status", default: "in_progress"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_by_id"], name: "index_rhythm_completions_on_completed_by_id"
    t.index ["rhythm_id", "completed_at"], name: "index_rhythm_completions_on_rhythm_id_and_completed_at"
    t.index ["rhythm_id"], name: "index_rhythm_completions_on_rhythm_id"
  end

  create_table "rhythms", force: :cascade do |t|
    t.bigint "family_id", null: false
    t.string "name", null: false
    t.string "frequency_type", default: "weekly", null: false
    t.integer "frequency_days", default: 7, null: false
    t.boolean "is_active", default: true
    t.datetime "next_due_at"
    t.datetime "last_completed_at"
    t.string "rhythm_category", default: "custom"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id", "is_active"], name: "index_rhythms_on_family_id_and_is_active"
    t.index ["family_id"], name: "index_rhythms_on_family_id"
    t.index ["next_due_at"], name: "index_rhythms_on_next_due_at"
  end

  create_table "thrive_assessments", force: :cascade do |t|
    t.bigint "member_id", null: false
    t.bigint "completed_by_id"
    t.bigint "rhythm_completion_id"
    t.integer "mind_rating"
    t.integer "body_rating"
    t.integer "spirit_rating"
    t.integer "responsibility_rating"
    t.text "mind_notes"
    t.text "body_notes"
    t.text "spirit_notes"
    t.text "responsibility_notes"
    t.text "whats_working"
    t.text "whats_not_working"
    t.text "action_items"
    t.datetime "assessed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_by_id"], name: "index_thrive_assessments_on_completed_by_id"
    t.index ["member_id", "assessed_at"], name: "index_thrive_assessments_on_member_id_and_assessed_at"
    t.index ["member_id"], name: "index_thrive_assessments_on_member_id"
    t.index ["rhythm_completion_id"], name: "index_thrive_assessments_on_rhythm_completion_id"
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
    t.bigint "current_family_id"
    t.index ["current_family_id"], name: "index_users_on_current_family_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "agenda_items", "rhythms"
  add_foreign_key "completion_items", "agenda_items"
  add_foreign_key "completion_items", "rhythm_completions"
  add_foreign_key "family_invitations", "families"
  add_foreign_key "family_invitations", "members"
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
  add_foreign_key "relationship_assessments", "relationships"
  add_foreign_key "relationship_assessments", "rhythm_completions"
  add_foreign_key "relationship_assessments", "users", column: "assessor_id"
  add_foreign_key "relationships", "families"
  add_foreign_key "relationships", "members", column: "member_high_id"
  add_foreign_key "relationships", "members", column: "member_low_id"
  add_foreign_key "rhythm_completions", "rhythms"
  add_foreign_key "rhythm_completions", "users", column: "completed_by_id"
  add_foreign_key "rhythms", "families"
  add_foreign_key "thrive_assessments", "members"
  add_foreign_key "thrive_assessments", "rhythm_completions"
  add_foreign_key "thrive_assessments", "users", column: "completed_by_id"
  add_foreign_key "users", "families"
  add_foreign_key "users", "families", column: "current_family_id"
end
