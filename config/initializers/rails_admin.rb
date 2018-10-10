RailsAdmin.config do |config|

  ### Popular gems integration

  # == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  config.authorize_with do
    unless current_user.admin?
      flash[:alert] = I18n.t('admin.authorization.not_authorized')
      redirect_to main_app.root_path
    end
  end

  ## == Cancan ==
  # config.authorize_with :cancan

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
            :Presentation]
    end
    new do
      only [:Publication, :User]
    end
    export
    bulk_delete do
      only [:Publication, :User]
    end
    show
    edit do
      only [:Publication, :User, :Contract, :Presentation]
    end
    delete do
      only [:Publication, :User]
    end
    show_in_app

    toggle
    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
