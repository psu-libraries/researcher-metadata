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

ActiveRecord::Schema.define(version: 2018_06_30_193214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorships", force: :cascade do |t|
    t.integer "person_id"
    t.integer "publication_id"
    t.integer "author_number"
    t.string "activity_insight_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_authorships_on_person_id"
    t.index ["publication_id"], name: "index_authorships_on_publication_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "activity_insight_identifier"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "institution"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publications", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "webaccess_id"
    t.integer "person_id"
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_users_on_person_id"
  end

  add_foreign_key "authorships", "people", name: "authorships_person_id_fk"
  add_foreign_key "authorships", "publications", name: "authorships_publication_id_fk"
  add_foreign_key "users", "people", name: "users_person_id_fk"
end
