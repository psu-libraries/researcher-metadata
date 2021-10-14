# frozen_string_literal: true

module Admin::Users
  extend ActiveSupport::Concern

  included do
    rails_admin do
      configure :publications do
        pretty_value do
          bindings[:view].render partial: 'rails_admin/partials/users/publications.html.erb', locals: { publications: value }
        end
      end

      list do
        field(:id) do
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:webaccess_id) { label 'Penn State WebAccess ID' }
        field(:first_name)
        field(:middle_name)
        field(:last_name)
        field(:open_access_notification_sent_at)
        field(:penn_state_identifier) do
          label 'Penn State ID'
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:pure_uuid) do
          label 'Pure ID'
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:activity_insight_identifier) do
          label 'Activity Insight ID'
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:orcid_identifier) do
          label 'ORCID'
          pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
        end
        field(:is_admin) do
          label 'Admin user?'
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:show_all_publications, :toggle)
        field(:show_all_contracts, :toggle)
        field(:scopus_h_index) do
          label 'H-Index'
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:created_at) do
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:updated_at) do
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:updated_by_user_at) do
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
      end

      show do
        field(:webaccess_id) { label 'Penn State WebAccess ID' }
        field(:pure_uuid) { label 'Pure ID' }
        field(:activity_insight_identifier) { label 'Activity Insight ID' }
        field(:penn_state_identifier) { label 'Penn State ID' }
        field(:scopus_h_index) { label 'H-Index' }
        field(:ai_title) { label 'Title' }
        field(:ai_rank) { label 'Rank' }
        field(:ai_endowed_title) { label 'Endowed Title' }
        field(:orcid_identifier) do
          label 'ORCID ID'
          pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
        end
        field(:ai_alt_name) { label 'Alternate Name' }
        field(:ai_building) { label 'Building' }
        field(:ai_room_number) { label 'Room Number' }
        field(:office_phone_number) { label 'Office Phone Number' }
        field(:fax_number) { label 'Fax Number' }
        field(:ai_website) { label 'Personal Website' }
        field(:ai_google_scholar) { label 'Google Scholar URL' }
        field(:ai_bio) { label 'Bio' }
        field(:ai_teaching_interests) { label 'Teaching Interests' }
        field(:ai_research_interests) { label 'Research Interests' }
        field(:education_history_items)
        field(:is_admin) { label 'Admin user?' }
        field(:show_all_publications)
        field(:show_all_contracts)
        field(:managed_organizations)
        field(:created_at)
        field(:updated_at)
        field(:updated_by_user_at)

        field(:publications)
        field(:presentations)
        field(:contracts)
        field(:grants)
        field(:etds)
        field(:news_feed_items)
        field(:user_organization_memberships)
        field(:organizations)
        field(:performances)
      end

      create do
        field(:webaccess_id) { label 'Penn State WebAccess ID' }
        field(:first_name)
        field(:middle_name)
        field(:last_name)
        field(:pure_uuid) { label 'Pure ID' }
        field(:activity_insight_identifier) { label 'Activity Insight ID' }
        field(:penn_state_identifier) { label 'Penn State ID' }
        field(:is_admin) { label 'Admin user?' }
        field(:show_all_publications)
        field(:show_all_contracts)
        field(:created_at) { read_only true }
        field(:updated_at) { read_only true }
        field(:updated_by_user_at) { read_only true }
      end

      edit do
        field(:webaccess_id) do
          read_only true
          label 'Penn State WebAccess ID'
        end
        field(:first_name) do
          read_only do
            !bindings[:view]._current_user.is_admin
          end
        end
        field(:middle_name) do
          read_only do
            !bindings[:view]._current_user.is_admin
          end
        end
        field(:last_name) do
          read_only do
            !bindings[:view]._current_user.is_admin
          end
        end
        field(:pure_uuid) do
          label 'Pure ID'
          read_only do
            !bindings[:view]._current_user.is_admin
          end
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:activity_insight_identifier) do
          label 'Activity Insight ID'
          read_only do
            !bindings[:view]._current_user.is_admin
          end
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:penn_state_identifier) do
          label 'Penn State ID'
          read_only do
            !bindings[:view]._current_user.is_admin
          end
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:is_admin) do
          label 'Admin user?'
          read_only do
            !bindings[:view]._current_user.is_admin
          end
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:show_all_publications)
        field(:show_all_contracts)
        field(:managed_organizations) do
          read_only do
            !bindings[:view]._current_user.is_admin
          end
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:user_organization_memberships) do
          read_only do
            !bindings[:view]._current_user.is_admin
          end
        end
        field(:created_at) do
          read_only true
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:updated_at) do
          read_only true
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
        field(:updated_by_user_at) do
          read_only true
          visible do
            bindings[:view]._current_user.is_admin
          end
        end
      end
    end
  end
end
