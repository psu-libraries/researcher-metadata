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

ActiveRecord::Schema[8.1].define(version: 2026_07_20_142612) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
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

  create_table "activity_insight_oa_files", force: :cascade do |t|
    t.boolean "checked_for_embargo_date"
    t.boolean "checked_for_set_statement"
    t.datetime "created_at", null: false
    t.boolean "downloaded"
    t.date "embargo_date"
    t.boolean "exported_oa_status_to_activity_insight"
    t.string "file_download_location"
    t.string "intellcont_id"
    t.string "license"
    t.string "location"
    t.datetime "permissions_last_checked_at", precision: nil
    t.string "post_file_id"
    t.bigint "publication_id", null: false
    t.text "set_statement"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "version"
    t.boolean "version_checked"
    t.integer "wrong_version_emails_sent"
    t.index ["publication_id"], name: "index_activity_insight_oa_files_on_publication_id"
    t.index ["user_id"], name: "index_activity_insight_oa_files_on_user_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string "admin_email"
    t.string "app_name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "last_used_at", precision: nil
    t.string "token", null: false
    t.integer "total_requests", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "write_access", default: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
  end

  create_table "authorships", force: :cascade do |t|
    t.integer "author_number"
    t.boolean "claimed_by_user", default: false
    t.boolean "confirmed", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "open_access_notification_sent_at", precision: nil
    t.string "orcid_resource_identifier"
    t.integer "position_in_profile"
    t.integer "publication_id", null: false
    t.string "role"
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "updated_by_owner_at", precision: nil
    t.integer "user_id", null: false
    t.boolean "visible_in_profile", default: true
    t.index ["publication_id"], name: "index_authorships_on_publication_id"
    t.index ["user_id"], name: "index_authorships_on_user_id"
  end

  create_table "committee_memberships", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "etd_id", null: false
    t.string "role", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.index ["etd_id"], name: "index_committee_memberships_on_etd_id"
    t.index ["user_id"], name: "index_committee_memberships_on_user_id"
  end

  create_table "contract_imports", force: :cascade do |t|
    t.bigint "activity_insight_id", null: false
    t.integer "contract_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["activity_insight_id"], name: "index_contract_imports_on_activity_insight_id", unique: true
    t.index ["contract_id"], name: "index_contract_imports_on_contract_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "amount", null: false
    t.date "award_end_on"
    t.date "award_start_on"
    t.string "contract_type"
    t.datetime "created_at", precision: nil, null: false
    t.integer "ospkey", null: false
    t.text "sponsor", null: false
    t.text "status", null: false
    t.text "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "visible", default: false
    t.index ["ospkey"], name: "index_contracts_on_ospkey", unique: true
  end

  create_table "contributor_names", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "middle_name"
    t.integer "position", null: false
    t.integer "publication_id", null: false
    t.string "role"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["publication_id"], name: "index_contributor_names_on_publication_id"
    t.index ["user_id"], name: "index_contributor_names_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at", precision: nil
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "deputy_assignments", force: :cascade do |t|
    t.bigint "active_uniqueness_key", default: 0
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "deactivated_at", precision: nil
    t.bigint "deputy_user_id"
    t.boolean "is_active"
    t.bigint "primary_user_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["deputy_user_id"], name: "index_deputy_assignments_on_deputy_user_id"
    t.index ["primary_user_id", "deputy_user_id", "active_uniqueness_key"], name: "index_deputy_assignments_on_unique_users_if_active", unique: true
    t.index ["primary_user_id"], name: "index_deputy_assignments_on_primary_user_id"
  end

  create_table "duplicate_publication_groups", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "education_history_items", force: :cascade do |t|
    t.string "activity_insight_identifier"
    t.text "comments"
    t.datetime "created_at", precision: nil, null: false
    t.string "degree"
    t.text "description"
    t.text "dissertation_or_thesis_title"
    t.text "emphasis_or_major"
    t.integer "end_year"
    t.text "explanation_of_other_degree"
    t.text "honor_or_distinction"
    t.text "institution"
    t.string "is_highest_degree_earned"
    t.string "is_honorary_degree"
    t.text "location_of_institution"
    t.text "school"
    t.integer "start_year"
    t.text "supporting_areas_of_emphasis"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.boolean "visible_in_profile", default: true, null: false
    t.index ["activity_insight_identifier"], name: "index_education_history_items_on_activity_insight_identifier", unique: true
    t.index ["user_id"], name: "index_education_history_items_on_user_id"
  end

  create_table "email_errors", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "message"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_email_errors_on_user_id"
  end

  create_table "etds", force: :cascade do |t|
    t.string "access_level", null: false
    t.string "author_first_name", null: false
    t.string "author_last_name", null: false
    t.string "author_middle_name"
    t.datetime "created_at", precision: nil, null: false
    t.string "external_identifier", null: false
    t.string "submission_type", null: false
    t.text "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "updated_by_user_at", precision: nil
    t.text "url", null: false
    t.string "webaccess_id", null: false
    t.integer "year", null: false
    t.index ["external_identifier"], name: "index_etds_on_external_identifier", unique: true
    t.index ["webaccess_id"], name: "index_etds_on_webaccess_id", unique: true
  end

  create_table "external_publication_waivers", force: :cascade do |t|
    t.text "abstract"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "deputy_user_id"
    t.string "doi"
    t.integer "internal_publication_waiver_id"
    t.string "journal_title", null: false
    t.text "publication_title", null: false
    t.string "publisher"
    t.text "reason_for_waiver"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.index ["deputy_user_id"], name: "index_external_publication_waivers_on_deputy_user_id"
    t.index ["internal_publication_waiver_id"], name: "index_external_waivers_on_internal_waiver_id"
    t.index ["user_id"], name: "index_external_publication_waivers_on_user_id"
  end

  create_table "grants", force: :cascade do |t|
    t.text "abstract"
    t.text "agency_name"
    t.integer "amount_in_dollars"
    t.datetime "created_at", precision: nil, null: false
    t.date "end_date"
    t.string "identifier"
    t.string "import_source", null: false
    t.date "start_date"
    t.text "title"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["agency_name"], name: "index_grants_on_agency_name"
    t.index ["identifier", "agency_name"], name: "index_grants_on_identifier_and_agency_name", unique: true
    t.index ["identifier"], name: "index_grants_on_identifier"
  end

  create_table "importer_error_logs", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "error_message", null: false
    t.string "error_type", null: false
    t.string "importer_type", null: false
    t.jsonb "metadata"
    t.datetime "occurred_at", precision: nil, null: false
    t.text "stacktrace", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["importer_type"], name: "index_importer_error_logs_on_importer_type"
  end

  create_table "imports", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "source", null: false
    t.datetime "started_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "internal_publication_waivers", force: :cascade do |t|
    t.integer "authorship_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.bigint "deputy_user_id"
    t.text "reason_for_waiver"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authorship_id"], name: "index_internal_publication_waivers_on_authorship_id"
    t.index ["deputy_user_id"], name: "index_internal_publication_waivers_on_deputy_user_id"
  end

  create_table "journals", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "publisher_id"
    t.string "pure_uuid"
    t.text "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publisher_id"], name: "index_journals_on_publisher_id"
  end

  create_table "news_feed_items", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description", null: false
    t.date "published_on", null: false
    t.string "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "url", null: false
    t.integer "user_id", null: false
    t.index ["url", "user_id"], name: "index_news_feed_items_on_url_and_user_id", unique: true
  end

  create_table "non_duplicate_publication_group_memberships", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "non_duplicate_publication_group_id", null: false
    t.integer "publication_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["non_duplicate_publication_group_id"], name: "index_ndpg_memberships_on_ndpg_id"
    t.index ["publication_id"], name: "index_ndpg_memberships_on_publication_id"
  end

  create_table "non_duplicate_publication_groups", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "oa_notification_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "email_cap"
    t.boolean "is_active"
    t.integer "singleton_guard"
    t.datetime "updated_at", null: false
    t.index ["singleton_guard"], name: "index_oa_notification_settings_on_singleton_guard", unique: true
  end

  create_table "open_access_locations", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.bigint "deputy_user_id"
    t.string "host_type"
    t.boolean "is_best"
    t.string "landing_page_url"
    t.string "license"
    t.date "oa_date"
    t.string "pdf_url"
    t.integer "publication_id"
    t.string "source"
    t.datetime "source_updated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.string "version"
    t.index ["deputy_user_id"], name: "index_open_access_locations_on_deputy_user_id"
    t.index ["publication_id"], name: "index_open_access_locations_on_publication_id"
  end

  create_table "organization_api_permissions", force: :cascade do |t|
    t.integer "api_token_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "organization_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["api_token_id"], name: "index_organization_api_permissions_on_api_token_id"
    t.index ["organization_id"], name: "index_organization_api_permissions_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "name", null: false
    t.string "organization_type"
    t.integer "owner_id"
    t.integer "parent_id"
    t.string "pure_external_identifier"
    t.string "pure_uuid"
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "visible", default: true
    t.index ["owner_id"], name: "index_organizations_on_owner_id"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
    t.index ["pure_uuid"], name: "index_organizations_on_pure_uuid", unique: true
  end

  create_table "performance_screenings", force: :cascade do |t|
    t.bigint "activity_insight_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "location"
    t.string "name"
    t.integer "performance_id", null: false
    t.string "screening_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["activity_insight_id"], name: "index_performance_screenings_on_activity_insight_id", unique: true
    t.index ["performance_id"], name: "index_performance_screenings_on_performance_id"
  end

  create_table "performances", force: :cascade do |t|
    t.bigint "activity_insight_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "delivery_type"
    t.text "description"
    t.date "end_on"
    t.text "group_name"
    t.text "location"
    t.string "performance_type"
    t.string "scope"
    t.text "sponsor"
    t.date "start_on"
    t.text "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "updated_by_user_at", precision: nil
    t.boolean "visible", default: true
    t.index ["activity_insight_id"], name: "index_performances_on_activity_insight_id", unique: true
  end

  create_table "presentation_contributions", force: :cascade do |t|
    t.string "activity_insight_identifier"
    t.datetime "created_at", precision: nil, null: false
    t.integer "position"
    t.integer "position_in_profile"
    t.integer "presentation_id", null: false
    t.string "role"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.boolean "visible_in_profile", default: false
    t.index ["activity_insight_identifier"], name: "index_presentation_contributions_on_activity_insight_identifier", unique: true
    t.index ["presentation_id"], name: "index_presentation_contributions_on_presentation_id"
    t.index ["user_id"], name: "index_presentation_contributions_on_user_id"
  end

  create_table "presentations", force: :cascade do |t|
    t.text "abstract"
    t.string "activity_insight_identifier", null: false
    t.integer "attendance"
    t.string "classification"
    t.text "comment"
    t.datetime "created_at", precision: nil, null: false
    t.date "ended_on"
    t.string "location"
    t.string "meet_type"
    t.text "name"
    t.string "organization"
    t.string "presentation_type"
    t.string "refereed"
    t.string "scope"
    t.date "started_on"
    t.text "title"
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "updated_by_user_at", precision: nil
    t.boolean "visible", default: true
    t.index ["activity_insight_identifier"], name: "index_presentations_on_activity_insight_identifier", unique: true
  end

  create_table "publication_imports", force: :cascade do |t|
    t.boolean "auto_merged"
    t.datetime "created_at", precision: nil, null: false
    t.integer "publication_id", null: false
    t.string "source", null: false
    t.string "source_identifier", null: false
    t.datetime "source_updated_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publication_id"], name: "index_publication_imports_on_publication_id"
    t.index ["source_identifier", "source"], name: "index_publication_imports_on_source_identifier_and_source", unique: true
  end

  create_table "publication_taggings", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "publication_id", null: false
    t.float "rank"
    t.integer "tag_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["publication_id"], name: "index_publication_taggings_on_publication_id"
    t.index ["tag_id"], name: "index_publication_taggings_on_tag_id"
  end

  create_table "publications", force: :cascade do |t|
    t.text "abstract"
    t.string "activity_insight_postprint_status"
    t.boolean "authors_et_al"
    t.datetime "created_at", precision: nil, null: false
    t.string "doi"
    t.boolean "doi_error"
    t.boolean "doi_verified"
    t.integer "duplicate_publication_group_id"
    t.string "edition"
    t.boolean "exported_to_activity_insight"
    t.boolean "flagged_for_review"
    t.integer "google_scholar_citation_count"
    t.string "isbn"
    t.string "issn"
    t.string "issue"
    t.integer "journal_id"
    t.text "journal_title"
    t.datetime "oa_status_last_checked_at", precision: nil
    t.string "oa_workflow_state"
    t.datetime "open_access_button_last_checked_at", precision: nil
    t.string "open_access_status"
    t.string "page_range"
    t.datetime "permissions_last_checked_at", precision: nil
    t.boolean "preferred_file_version_none_email_sent"
    t.string "preferred_version"
    t.string "publication_type", null: false
    t.date "published_on"
    t.text "publisher_name"
    t.text "secondary_title"
    t.string "status"
    t.text "title", null: false
    t.integer "total_scopus_citations"
    t.datetime "unpaywall_last_checked_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "updated_by_user_at", precision: nil
    t.text "url"
    t.boolean "visible", default: true
    t.string "volume"
    t.datetime "wrong_oa_version_notification_sent_at", precision: nil
    t.index "EXTRACT(year FROM published_on)", name: "index_publications_on_published_on_year"
    t.index ["doi"], name: "index_publications_on_doi"
    t.index ["duplicate_publication_group_id"], name: "index_publications_on_duplicate_publication_group_id"
    t.index ["google_scholar_citation_count"], name: "index_publications_on_google_scholar_citation_count"
    t.index ["issue"], name: "index_publications_on_issue"
    t.index ["journal_id"], name: "index_publications_on_journal_id"
    t.index ["published_on"], name: "index_publications_on_published_on"
    t.index ["volume"], name: "index_publications_on_volume"
  end

  create_table "publishers", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "name", null: false
    t.string "pure_uuid"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "research_funds", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "grant_id", null: false
    t.string "import_source", null: false
    t.integer "publication_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["grant_id"], name: "index_research_funds_on_grant_id"
    t.index ["publication_id"], name: "index_research_funds_on_publication_id"
  end

  create_table "researcher_funds", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "grant_id", null: false
    t.string "import_source", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.index ["grant_id"], name: "index_researcher_funds_on_grant_id"
    t.index ["user_id"], name: "index_researcher_funds_on_user_id"
  end

  create_table "scholarsphere_file_uploads", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "file"
    t.integer "scholarsphere_work_deposit_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["scholarsphere_work_deposit_id"], name: "scholarsphere_file_uploads_on_deposit_id"
  end

  create_table "scholarsphere_work_deposits", force: :cascade do |t|
    t.integer "activity_insight_oa_file_id"
    t.bigint "authorship_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "deposit_workflow"
    t.datetime "deposited_at", precision: nil
    t.bigint "deputy_user_id"
    t.text "description"
    t.string "doi"
    t.string "draft_scholarsphere_work_deposit_url"
    t.date "embargoed_until"
    t.text "error_message"
    t.date "published_date"
    t.string "publisher"
    t.text "publisher_statement"
    t.string "rights"
    t.string "scholarsphere_edit_url"
    t.string "status"
    t.text "subtitle"
    t.text "title"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authorship_id"], name: "index_scholarsphere_work_deposits_on_authorship_id"
    t.index ["deputy_user_id"], name: "index_scholarsphere_work_deposits_on_deputy_user_id"
  end

  create_table "source_publications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "import_id", null: false
    t.string "source_identifier", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_source_publications_on_import_id"
  end

  create_table "statistics_snapshots", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "open_access_article_count"
    t.integer "total_article_count"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.string "source"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "user_contracts", force: :cascade do |t|
    t.integer "contract_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.index ["contract_id"], name: "index_user_contracts_on_contract_id"
    t.index ["user_id"], name: "index_user_contracts_on_user_id"
  end

  create_table "user_organization_memberships", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.date "ended_on"
    t.string "import_source"
    t.string "orcid_resource_identifier"
    t.integer "organization_id", null: false
    t.string "position_title"
    t.boolean "primary"
    t.string "source_identifier"
    t.date "started_on"
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "updated_by_user_at", precision: nil
    t.integer "user_id", null: false
    t.index ["import_source"], name: "index_user_organization_memberships_on_import_source"
    t.index ["organization_id"], name: "index_user_organization_memberships_on_organization_id"
    t.index ["source_identifier"], name: "index_user_organization_memberships_on_source_identifier"
    t.index ["user_id"], name: "index_user_organization_memberships_on_user_id"
  end

  create_table "user_performances", force: :cascade do |t|
    t.bigint "activity_insight_id", null: false
    t.string "contribution"
    t.datetime "created_at", precision: nil, null: false
    t.integer "performance_id", null: false
    t.integer "position_in_profile"
    t.string "role_other"
    t.string "student_level"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.boolean "visible_in_profile", default: true
    t.index ["activity_insight_id"], name: "index_user_performances_on_activity_insight_id", unique: true
    t.index ["performance_id"], name: "index_user_performances_on_performance_id"
    t.index ["user_id"], name: "index_user_performances_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "activity_insight_identifier"
    t.string "ai_alt_name"
    t.text "ai_bio"
    t.string "ai_building"
    t.string "ai_fax_1"
    t.string "ai_fax_2"
    t.string "ai_fax_area_code"
    t.text "ai_google_scholar"
    t.string "ai_office_area_code"
    t.string "ai_office_phone_1"
    t.string "ai_office_phone_2"
    t.text "ai_research_interests"
    t.string "ai_room_number"
    t.text "ai_teaching_interests"
    t.string "ai_title"
    t.text "ai_website"
    t.string "authenticated_orcid_identifier"
    t.datetime "created_at", precision: nil, null: false
    t.string "first_name"
    t.datetime "google_scholar_checked_at"
    t.integer "google_scholar_citation_total"
    t.integer "google_scholar_h_index"
    t.string "google_scholar_id"
    t.datetime "google_scholar_imported_at"
    t.boolean "google_scholar_not_found", default: false, null: false
    t.boolean "is_admin", default: false
    t.string "last_name"
    t.string "middle_name"
    t.datetime "open_access_notification_sent_at", precision: nil
    t.string "orcid_access_token"
    t.integer "orcid_access_token_expires_in"
    t.string "orcid_access_token_scope"
    t.string "orcid_identifier"
    t.string "orcid_refresh_token"
    t.string "penn_state_identifier"
    t.string "provider"
    t.jsonb "psu_identity"
    t.datetime "psu_identity_updated_at", precision: nil
    t.string "pure_uuid"
    t.integer "scopus_h_index"
    t.boolean "show_all_contracts", default: false
    t.boolean "show_all_publications", default: true
    t.boolean "suppress_oa_reminders", default: false
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "updated_by_user_at", precision: nil
    t.string "webaccess_id", null: false
    t.index ["activity_insight_identifier"], name: "index_users_on_activity_insight_identifier", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["google_scholar_id"], name: "index_users_on_google_scholar_id", unique: true
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["middle_name"], name: "index_users_on_middle_name"
    t.index ["orcid_identifier"], name: "index_users_on_orcid_identifier", unique: true
    t.index ["penn_state_identifier"], name: "index_users_on_penn_state_identifier", unique: true
    t.index ["pure_uuid"], name: "index_users_on_pure_uuid", unique: true
    t.index ["webaccess_id"], name: "index_users_on_webaccess_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_insight_oa_files", "publications", name: "activity_insight_oa_files_publication_id_fk", on_delete: :cascade
  add_foreign_key "activity_insight_oa_files", "users", name: "activity_insight_oa_files_user_id_fk"
  add_foreign_key "authorships", "publications", on_delete: :cascade
  add_foreign_key "authorships", "users", on_delete: :cascade
  add_foreign_key "committee_memberships", "etds", on_delete: :cascade
  add_foreign_key "committee_memberships", "users", on_delete: :cascade
  add_foreign_key "contract_imports", "contracts", on_delete: :cascade
  add_foreign_key "contributor_names", "publications", on_delete: :cascade
  add_foreign_key "contributor_names", "users"
  add_foreign_key "deputy_assignments", "users", column: "deputy_user_id"
  add_foreign_key "deputy_assignments", "users", column: "primary_user_id"
  add_foreign_key "education_history_items", "users", on_delete: :cascade
  add_foreign_key "email_errors", "users", name: "email_errors_user_id_fk"
  add_foreign_key "external_publication_waivers", "internal_publication_waivers", name: "external_publication_waivers_internal_publication_waiver_id_fk"
  add_foreign_key "external_publication_waivers", "users", column: "deputy_user_id", name: "external_publication_waivers_deputy_user_id_fk"
  add_foreign_key "external_publication_waivers", "users", name: "external_publication_waivers_user_id_fk"
  add_foreign_key "internal_publication_waivers", "authorships", name: "internal_publication_waivers_authorship_id_fk"
  add_foreign_key "internal_publication_waivers", "users", column: "deputy_user_id", name: "internal_publication_waivers_deputy_user_id_fk"
  add_foreign_key "journals", "publishers"
  add_foreign_key "news_feed_items", "users"
  add_foreign_key "non_duplicate_publication_group_memberships", "non_duplicate_publication_groups", name: "non_duplicate_publication_group_membership_group_id_fk", on_delete: :cascade
  add_foreign_key "non_duplicate_publication_group_memberships", "publications", name: "non_duplicate_publication_group_membership_publication_id_fk", on_delete: :cascade
  add_foreign_key "open_access_locations", "publications", name: "open_access_locations_publication_id_fk", on_delete: :cascade
  add_foreign_key "open_access_locations", "users", column: "deputy_user_id", name: "open_access_locations_deputy_user_id_fk"
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
  add_foreign_key "publications", "journals"
  add_foreign_key "research_funds", "grants", name: "research_funds_grant_id_fk", on_delete: :cascade
  add_foreign_key "research_funds", "publications", name: "research_funds_publication_id_fk", on_delete: :cascade
  add_foreign_key "researcher_funds", "grants", name: "research_funds_grant_id_fk", on_delete: :cascade
  add_foreign_key "researcher_funds", "users", name: "research_funds_user_id_fk", on_delete: :cascade
  add_foreign_key "scholarsphere_file_uploads", "scholarsphere_work_deposits", name: "scholarsphere_file_uploads_deposit_id_fk"
  add_foreign_key "scholarsphere_work_deposits", "authorships"
  add_foreign_key "scholarsphere_work_deposits", "users", column: "deputy_user_id", name: "scholarsphere_work_deposits_deputy_user_id_fk"
  add_foreign_key "source_publications", "imports"
  add_foreign_key "user_contracts", "contracts", on_delete: :cascade
  add_foreign_key "user_contracts", "users", on_delete: :cascade
  add_foreign_key "user_organization_memberships", "organizations", name: "user_organization_memberships_organization_id_fk", on_delete: :cascade
  add_foreign_key "user_organization_memberships", "users", name: "user_organization_memberships_user_id_fk", on_delete: :cascade
  add_foreign_key "user_performances", "performances", on_delete: :cascade
  add_foreign_key "user_performances", "users", on_delete: :cascade
end
