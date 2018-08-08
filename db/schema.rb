# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_08_215350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "publication_id", null: false
    t.integer "author_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_authorships_on_publication_id"
    t.index ["user_id"], name: "index_authorships_on_user_id"
  end

  create_table "contributors", force: :cascade do |t|
    t.integer "publication_id", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_contributors_on_publication_id"
  end

  create_table "duplicate_publication_groups", force: :cascade do |t|
    t.text "title"
    t.text "journal"
    t.string "issue"
    t.string "volume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publication_imports", force: :cascade do |t|
    t.integer "publication_id", null: false
    t.string "source", null: false
    t.string "source_identifier", null: false
    t.datetime "source_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_publication_imports_on_publication_id"
    t.index ["source_identifier", "source"], name: "index_publication_imports_on_source_identifier_and_source", unique: true
  end

  create_table "publications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "title", null: false
    t.string "publication_type", null: false
    t.text "journal_title"
    t.text "publisher"
    t.text "secondary_title"
    t.string "status"
    t.string "volume"
    t.string "issue"
    t.string "edition"
    t.string "page_range"
    t.text "url"
    t.string "isbn"
    t.string "issn"
    t.string "doi"
    t.text "abstract"
    t.boolean "authors_et_al"
    t.date "published_on"
    t.integer "citation_count"
    t.integer "duplicate_publication_group_id"
    t.index ["duplicate_publication_group_id"], name: "index_publications_on_duplicate_publication_group_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "activity_insight_identifier"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.string "webaccess_id", null: false
    t.string "pure_uuid"
    t.string "penn_state_identifier"
    t.index ["activity_insight_identifier"], name: "index_users_on_activity_insight_identifier", unique: true
    t.index ["pure_uuid"], name: "index_users_on_pure_uuid", unique: true
    t.index ["webaccess_id"], name: "index_users_on_webaccess_id", unique: true
  end

  add_foreign_key "authorships", "publications", on_delete: :cascade
  add_foreign_key "authorships", "users", on_delete: :cascade
  add_foreign_key "contributors", "publications", on_delete: :cascade
  add_foreign_key "publication_imports", "publications", name: "publication_imports_publication_id_fk"
  add_foreign_key "publications", "duplicate_publication_groups", name: "publications_duplicate_publication_group_id_fk"
end
