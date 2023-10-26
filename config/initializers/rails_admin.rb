# frozen_string_literal: true
Rails.application.config.to_prepare do
  require_relative '../../app/rails_admin_actions/index_publications_by_organization'
  require_relative '../../app/rails_admin_actions/export_publications_by_organization'
  require_relative '../../app/rails_admin_actions/export_publications_to_activity_insight'
  require_relative '../../app/rails_admin_actions/delete'
  require_relative '../../app/rails_admin_actions/edit'
  require_relative '../../app/rails_admin_actions/new'

  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::IndexPublicationsByOrganization)
  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::ExportPublicationsByOrganization)
  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::ExportPublicationsToActivityInsight)

  RailsAdmin.config do |config|
    config.asset_source = :webpack
    config.parent_controller = 'ApplicationController'

    ### Popular gems integration

    # == Devise ==
    config.authenticate_with do
      warden.authenticate! scope: :user
    end
    config.current_user_method(&:current_user)

    ## == CancanCan ==
    config.authorize_with :cancancan

    ## == Pundit ==
    # config.authorize_with :pundit

    ## == PaperTrail ==
    # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

    ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

    ## == Gravatar integration ==
    ## To disable Gravatar integration in Navigation Bar set to false
    # config.show_gravatar = true

    config.excluded_models = [
      'ActiveStorage::Blob',
      'ActiveStorage::Attachment'
    ]

    config.default_associated_collection_limit = 1000

    config.actions do
      dashboard do
        #     statistics false
      end
      index do
        only [:Publication,
              :User,
              :DuplicatePublicationGroup,
              :ETD,
              :Presentation,
              :Organization,
              :NewsFeedItem,
              :Performance,
              :APIToken,
              :Grant,
              :InternalPublicationWaiver,
              :ExternalPublicationWaiver,
              :Journal,
              :Publisher,
              :StatisticsSnapshot,
              :EmailError,
              :ScholarsphereWorkDeposit,
              :ImporterErrorLog,
              :Authorship,
              :OANotificationSetting,
              :ActivityInsightOAFile]
      end
      new do
        only [:Authorship,
              :Publication,
              :User,
              :APIToken,
              :ExternalPublicationWaiver,
              :InternalPublicationWaiver,
              :OpenAccessLocation]
      end
      export
      bulk_delete do
        only [:Publication, :User, :ImporterErrorLog]
      end
      show do
      end
      edit do
        only [:Authorship,
              :Publication,
              :User,
              :Presentation,
              :Performance,
              :APIToken,
              :ExternalPublicationWaiver,
              :InternalPublicationWaiver,
              :OpenAccessLocation,
              :OANotificationSetting,
              :ActivityInsightOAFile]
      end
      delete do
        only [:APIToken,
              :ExternalPublicationWaiver,
              :ImporterErrorLog,
              :OpenAccessLocation,
              :Publication,
              :User,
              :Authorship]
      end
      index_publications_by_organization do
        only [:Publication]
        visible do
          false
        end
      end
      export_publications_by_organization do
        only [:Publication]
        visible do
          false
        end
      end
      export_publications_to_activity_insight do
      end

      toggle
      ## With an audit adapter, you can add:
      # history_index
      # history_show
    end

    config.compact_show_view = false

    # Non-rails-admin links
    config.navigation_static_label = 'Workflows'
    config.navigation_static_links = {
      'Activity Insight Open Access Workflow' => '/activity_insight_oa_workflow'
    }
  end
end
