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

ActiveRecord::Schema.define(version: 2020_05_19_201649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "app_name"
    t.string "admin_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_requests", default: 0
    t.datetime "last_used_at"
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
  end

  create_table "authorships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "publication_id", null: false
    t.integer "author_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible_in_profile", default: true
    t.integer "position_in_profile"
    t.boolean "confirmed", default: true
    t.datetime "scholarsphere_uploaded_at"
    t.string "role"
    t.index ["publication_id"], name: "index_authorships_on_publication_id"
    t.index ["user_id"], name: "index_authorships_on_user_id"
  end

  create_table "committee_memberships", force: :cascade do |t|
    t.integer "etd_id", null: false
    t.integer "user_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["etd_id"], name: "index_committee_memberships_on_etd_id"
    t.index ["user_id"], name: "index_committee_memberships_on_user_id"
  end

  create_table "contract_imports", force: :cascade do |t|
    t.integer "contract_id", null: false
    t.bigint "activity_insight_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_insight_id"], name: "index_contract_imports_on_activity_insight_id", unique: true
    t.index ["contract_id"], name: "index_contract_imports_on_contract_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.text "title", null: false
    t.string "contract_type"
    t.text "sponsor", null: false
    t.text "status", null: false
    t.integer "amount", null: false
    t.integer "ospkey", null: false
    t.date "award_start_on"
    t.date "award_end_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: false
    t.index ["ospkey"], name: "index_contracts_on_ospkey", unique: true
  end

  create_table "contributors", force: :cascade do |t|
    t.integer "publication_id", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.index ["publication_id"], name: "index_contributors_on_publication_id"
  end

  create_table "duplicate_publication_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "education_history_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "activity_insight_identifier"
    t.string "degree"
    t.text "explanation_of_other_degree"
    t.string "is_honorary_degree"
    t.string "is_highest_degree_earned"
    t.text "institution"
    t.text "school"
    t.text "location_of_institution"
    t.text "emphasis_or_major"
    t.text "supporting_areas_of_emphasis"
    t.text "dissertation_or_thesis_title"
    t.text "honor_or_distinction"
    t.text "description"
    t.text "comments"
    t.integer "start_year"
    t.integer "end_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_insight_identifier"], name: "index_education_history_items_on_activity_insight_identifier", unique: true
    t.index ["user_id"], name: "index_education_history_items_on_user_id"
  end

  create_table "etds", force: :cascade do |t|
    t.text "title", null: false
    t.string "author_first_name", null: false
    t.string "author_last_name", null: false
    t.string "author_middle_name"
    t.string "webaccess_id", null: false
    t.integer "year", null: false
    t.text "url", null: false
    t.string "submission_type", null: false
    t.string "external_identifier", null: false
    t.string "access_level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "updated_by_user_at"
    t.index ["external_identifier"], name: "index_etds_on_external_identifier", unique: true
    t.index ["webaccess_id"], name: "index_etds_on_webaccess_id", unique: true
  end

  create_table "external_publication_waivers", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "publication_title", null: false
    t.text "reason_for_waiver"
    t.text "abstract"
    t.string "doi"
    t.string "journal_title", null: false
    t.string "publisher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_external_publication_waivers_on_user_id"
  end

  create_table "grants", force: :cascade do |t|
    t.text "wos_agency_name"
    t.string "wos_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "title"
    t.date "start_date"
    t.date "end_date"
    t.text "abstract"
    t.integer "amount_in_dollars"
    t.string "identifier"
    t.text "agency_name"
    t.index ["agency_name"], name: "index_grants_on_agency_name"
    t.index ["identifier"], name: "index_grants_on_identifier"
    t.index ["wos_agency_name"], name: "index_grants_on_wos_agency_name"
    t.index ["wos_identifier"], name: "index_grants_on_wos_identifier"
  end

  create_table "internal_publication_waivers", force: :cascade do |t|
    t.integer "authorship_id", null: false
    t.text "reason_for_waiver"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authorship_id"], name: "index_internal_publication_waivers_on_authorship_id"
  end

  create_table "news_feed_items", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "url", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "published_on", null: false
    t.index ["url", "user_id"], name: "index_news_feed_items_on_url_and_user_id", unique: true
  end

  create_table "organization_api_permissions", force: :cascade do |t|
    t.integer "api_token_id", null: false
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token_id"], name: "index_organization_api_permissions_on_api_token_id"
    t.index ["organization_id"], name: "index_organization_api_permissions_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.text "name", null: false
    t.boolean "visible", default: true
    t.string "pure_uuid"
    t.string "pure_external_identifier"
    t.string "organization_type"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
    t.index ["pure_uuid"], name: "index_organizations_on_pure_uuid", unique: true
  end

  create_table "performance_screenings", force: :cascade do |t|
    t.integer "performance_id", null: false
    t.string "screening_type"
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "activity_insight_id", null: false
    t.index ["activity_insight_id"], name: "index_performance_screenings_on_activity_insight_id", unique: true
    t.index ["performance_id"], name: "index_performance_screenings_on_performance_id"
  end

  create_table "performances", force: :cascade do |t|
    t.text "title", null: false
    t.string "performance_type"
    t.text "sponsor"
    t.text "description"
    t.text "group_name"
    t.text "location"
    t.string "delivery_type"
    t.string "scope"
    t.date "start_on"
    t.date "end_on"
    t.datetime "updated_by_user_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true
    t.bigint "activity_insight_id", null: false
    t.index ["activity_insight_id"], name: "index_performances_on_activity_insight_id", unique: true
  end

  create_table "presentation_contributions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "presentation_id", null: false
    t.integer "position"
    t.string "activity_insight_identifier"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible_in_profile", default: true
    t.integer "position_in_profile"
    t.index ["activity_insight_identifier"], name: "index_presentation_contributions_on_activity_insight_identifier", unique: true
    t.index ["presentation_id"], name: "index_presentation_contributions_on_presentation_id"
    t.index ["user_id"], name: "index_presentation_contributions_on_user_id"
  end

  create_table "presentations", force: :cascade do |t|
    t.text "title"
    t.string "activity_insight_identifier", null: false
    t.text "name"
    t.string "organization"
    t.string "location"
    t.date "started_on"
    t.date "ended_on"
    t.string "presentation_type"
    t.string "classification"
    t.string "meet_type"
    t.integer "attendance"
    t.string "refereed"
    t.text "abstract"
    t.text "comment"
    t.string "scope"
    t.datetime "updated_by_user_at"
    t.boolean "visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_insight_identifier"], name: "index_presentations_on_activity_insight_identifier", unique: true
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

  create_table "publication_taggings", force: :cascade do |t|
    t.integer "publication_id", null: false
    t.integer "tag_id", null: false
    t.float "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["publication_id"], name: "index_publication_taggings_on_publication_id"
    t.index ["tag_id"], name: "index_publication_taggings_on_tag_id"
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
    t.integer "total_scopus_citations"
    t.integer "duplicate_publication_group_id"
    t.datetime "updated_by_user_at"
    t.boolean "visible", default: true
    t.text "open_access_url"
    t.datetime "open_access_button_last_checked_at"
    t.text "user_submitted_open_access_url"
    t.index ["doi"], name: "index_publications_on_doi"
    t.index ["duplicate_publication_group_id"], name: "index_publications_on_duplicate_publication_group_id"
    t.index ["issue"], name: "index_publications_on_issue"
    t.index ["volume"], name: "index_publications_on_volume"
  end

  create_table "research_funds", force: :cascade do |t|
    t.integer "grant_id", null: false
    t.integer "publication_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_id"], name: "index_research_funds_on_grant_id"
    t.index ["publication_id"], name: "index_research_funds_on_publication_id"
  end

  create_table "researcher_funds", force: :cascade do |t|
    t.integer "grant_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_id"], name: "index_researcher_funds_on_grant_id"
    t.index ["user_id"], name: "index_researcher_funds_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "user_contracts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "contract_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_user_contracts_on_contract_id"
    t.index ["user_id"], name: "index_user_contracts_on_user_id"
  end

  create_table "user_organization_memberships", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "organization_id", null: false
    t.string "pure_identifier"
    t.boolean "imported_from_pure"
    t.string "position_title"
    t.boolean "primary"
    t.datetime "updated_by_user_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "started_on"
    t.date "ended_on"
    t.string "orcid_resource_identifier"
    t.index ["organization_id"], name: "index_user_organization_memberships_on_organization_id"
    t.index ["pure_identifier"], name: "index_user_organization_memberships_on_pure_identifier"
    t.index ["user_id"], name: "index_user_organization_memberships_on_user_id"
  end

  create_table "user_performances", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "performance_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contribution"
    t.string "student_level"
    t.string "role_other"
    t.bigint "activity_insight_id", null: false
    t.boolean "visible_in_profile", default: true
    t.integer "position_in_profile"
    t.index ["activity_insight_id"], name: "index_user_performances_on_activity_insight_id", unique: true
    t.index ["performance_id"], name: "index_user_performances_on_performance_id"
    t.index ["user_id"], name: "index_user_performances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "activity_insight_identifier"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.string "webaccess_id", null: false
    t.string "pure_uuid"
    t.string "penn_state_identifier"
    t.datetime "updated_by_user_at"
    t.boolean "show_all_publications", default: true
    t.boolean "show_all_contracts", default: false
    t.integer "scopus_h_index"
    t.string "ai_title"
    t.string "ai_rank"
    t.string "ai_endowed_title"
    t.string "orcid_identifier"
    t.string "ai_alt_name"
    t.string "ai_building"
    t.string "ai_room_number"
    t.integer "ai_office_area_code"
    t.integer "ai_office_phone_1"
    t.integer "ai_office_phone_2"
    t.integer "ai_fax_area_code"
    t.integer "ai_fax_1"
    t.integer "ai_fax_2"
    t.text "ai_website"
    t.text "ai_bio"
    t.text "ai_teaching_interests"
    t.text "ai_research_interests"
    t.text "ai_google_scholar"
    t.string "orcid_access_token"
    t.index ["activity_insight_identifier"], name: "index_users_on_activity_insight_identifier", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["middle_name"], name: "index_users_on_middle_name"
    t.index ["orcid_identifier"], name: "index_users_on_orcid_identifier", unique: true
    t.index ["penn_state_identifier"], name: "index_users_on_penn_state_identifier", unique: true
    t.index ["pure_uuid"], name: "index_users_on_pure_uuid", unique: true
    t.index ["webaccess_id"], name: "index_users_on_webaccess_id", unique: true
  end

  add_foreign_key "authorships", "publications", on_delete: :cascade
  add_foreign_key "authorships", "users", on_delete: :cascade
  add_foreign_key "committee_memberships", "etds", on_delete: :cascade
  add_foreign_key "committee_memberships", "users", on_delete: :cascade
  add_foreign_key "contract_imports", "contracts", on_delete: :cascade
  add_foreign_key "contributors", "publications", on_delete: :cascade
  add_foreign_key "education_history_items", "users", on_delete: :cascade
  add_foreign_key "external_publication_waivers", "users", name: "external_publication_waivers_user_id_fk"
  add_foreign_key "internal_publication_waivers", "authorships", name: "internal_publication_waivers_authorship_id_fk"
  add_foreign_key "news_feed_items", "users"
  add_foreign_key "organization_api_permissions", "api_tokens", name: "organization_api_permissions_api_token_id_fk", on_delete: :cascade
  add_foreign_key "organization_api_permissions", "organizations", name: "organization_api_permissions_organization_id_fk", on_delete: :cascade
  add_foreign_key "organizations", "organizations", column: "parent_id", name: "organizations_parent_id_fk", on_delete: :restrict
  add_foreign_key "organizations", "users", column: "owner_id", name: "organizations_owner_id_fk"
  add_foreign_key "performance_screenings", "performances", on_delete: :cascade
  add_foreign_key "presentation_contributions", "presentations", name: "presentation_contributions_presentation_id_fk", on_delete: :cascade
  add_foreign_key "presentation_contributions", "users", name: "presentation_contributions_user_id_fk", on_delete: :cascade
  add_foreign_key "publication_imports", "publications", name: "publication_imports_publication_id_fk"
  add_foreign_key "publication_taggings", "publications", on_delete: :cascade
  add_foreign_key "publication_taggings", "tags", on_delete: :cascade
  add_foreign_key "publications", "duplicate_publication_groups", name: "publications_duplicate_publication_group_id_fk"
  add_foreign_key "research_funds", "grants", name: "research_funds_grant_id_fk", on_delete: :cascade
  add_foreign_key "research_funds", "publications", name: "research_funds_publication_id_fk", on_delete: :cascade
  add_foreign_key "researcher_funds", "grants", name: "research_funds_grant_id_fk", on_delete: :cascade
  add_foreign_key "researcher_funds", "users", name: "research_funds_user_id_fk", on_delete: :cascade
  add_foreign_key "user_contracts", "contracts", on_delete: :cascade
  add_foreign_key "user_contracts", "users", on_delete: :cascade
  add_foreign_key "user_organization_memberships", "organizations", name: "user_organization_memberships_organization_id_fk", on_delete: :cascade
  add_foreign_key "user_organization_memberships", "users", name: "user_organization_memberships_user_id_fk", on_delete: :cascade
  add_foreign_key "user_performances", "performances", on_delete: :cascade
  add_foreign_key "user_performances", "users", on_delete: :cascade
end
