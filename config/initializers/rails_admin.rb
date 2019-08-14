RailsAdmin.config do |config|

  config.parent_controller = 'ApplicationController'

  ### Popular gems integration

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # == Cancan ==
  config.authorize_with :cancan

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
            :Contract,
            :Presentation,
            :Organization,
            :NewsFeedItem,
            :Performance,
            :APIToken]
    end
    new do
      only [:Publication, :User, :APIToken]
    end
    export
    bulk_delete do
      only [:Publication, :User]
    end
    show
    edit do
      only [:Publication, :User, :Contract, :Presentation, :Performance, :APIToken]
    end
    delete do
      only [:Publication, :User, :APIToken]
    end
    show_in_app

    toggle
    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
