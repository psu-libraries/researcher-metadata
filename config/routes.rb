# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  mount OkComputer::Engine, at: '/health'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    match 'sign_out', to: 'devise/sessions#destroy', via: [:get, :delete], as: :destroy_user_session
  end

  authenticated :user, ->(user) { user.admin? } do
    mount DelayedJobWeb, at: '/delayed_job'
  end

  namespace :admin do
    post 'duplicate_publication_group/:duplicate_publication_group_id/merge' => 'publication_merges#create', as: :duplicate_publication_group_merge
    delete 'duplicate_publication_group/:id' => 'duplicate_publication_groups#delete', as: :duplicate_publication_group
    post 'external_publication_waivers/:external_publication_waiver_id/link' => 'publication_waiver_links#create', as: :publication_waiver_link

    scope 'user/:user_id' do
      post 'duplicate_publication_groupings' => 'duplicate_publication_groupings#create', as: :user_duplicate_publication_groupings
      post 'unbecome' => 'masquerade#unbecome', as: :unbecomes_user
      post 'become' => 'masquerade#become', as: :becomes_user
    end
  end

  get '/activity_insight_oa_workflow' => 'activity_insight_oa_workflow#index'
  namespace :activity_insight_oa_workflow do
    get '/doi_verification' => 'doi_verification#index'
    get '/file_version_review' => 'file_version_curation#index'
    get '/wrong_file_version_review' => 'wrong_file_version_curation#index'
    post '/wrong_file_version_email' => 'wrong_file_version_curation#email_author'
    get '/preferred_version_review' => 'preferred_version_curation#index'
    get '/permissions_review' => 'permissions_curation#index'
    get '/files/:activity_insight_oa_file_id/download' => 'files#download', as: :file_download
    get '/metadata_review' => 'metadata_curation#index'
    get '/all_workflow_publications' => 'all_workflow_publications#index'
  end

  root to: 'public#home'
  get '/resources' => 'public#resources', as: :resources
  get '/api_docs' => 'public#api_docs', as: :api_docs

  scope module: 'api' do
    namespace :v1 do
      get 'publications' => 'publications#index', as: :publications
      patch 'publications' => 'publications#update_all'
      get 'publications/:id' => 'publications#show', as: :publication
      get 'publications/:id/grants' => 'publications#grants', as: :publication_grants

      get 'users/:webaccess_id/publications' => 'users#publications', as: :user_publications
      get 'users/:webaccess_id/grants' => 'users#grants', as: :user_grants
      get 'users/:webaccess_id/news_feed_items' => 'users#news_feed_items', as: :user_news_feed_items
      get 'users/:webaccess_id/performances' => 'users#performances', as: :user_performances
      post 'users/publications' => 'users#users_publications', as: :users_publications
      get 'users/:webaccess_id/etds' => 'users#etds', as: :user_etds
      get 'users/:webaccess_id/presentations' => 'users#presentations', as: :user_presentations
      get 'users/:webaccess_id/organization_memberships' => 'users#organization_memberships', as: :user_organization_memberships
      get 'users/:webaccess_id/profile' => 'users#profile', as: :user_profile

      get 'organizations' => 'organizations#index', as: :organizations
      get 'organizations/:id/publications' => 'organizations#publications', as: :organization_publications
    end
  end

  get 'profiles/:webaccess_id' => 'profiles#show', as: :profile

  get 'profile' => redirect('profile/publications/edit')
  scope 'profile' do
    get 'search_publications' => 'publications#index', as: :publications
    get 'search_publications/:id' => 'publications#show', as: :publication
    get 'publications/edit' => 'profiles#edit_publications', as: :edit_profile_publications
    get 'presentations/edit' => 'profiles#edit_presentations', as: :edit_profile_presentations
    get 'performances/edit' => 'profiles#edit_performances', as: :edit_profile_performances
    get 'other_publications/edit' => 'profiles#edit_other_publications', as: :edit_profile_other_publications
    get 'bio' => 'profiles#bio', as: :profile_bio
    post 'bio/orcid/employments/:membership_id' => 'orcid_employments#create', as: :orcid_employments
    post 'bio/orcid/works' => 'orcid_works#create', as: :orcid_works
    get 'publications/:id/open_access/edit' => 'open_access_publications#edit', as: :edit_open_access_publication
    post 'publications/:id/open_access/scholarsphere_file_version' => 'open_access_publications#scholarsphere_file_version', as: :scholarsphere_file_version
    get 'publications/:id/open_access/file_version_result' => 'open_access_publications#file_version_result', as: :file_version_result
    post 'publications/:id/open_access/scholarsphere_deposit_form' => 'open_access_publications#scholarsphere_deposit_form', as: :scholarsphere_deposit_form
    get 'publications/:id/open_access/scholarsphere_file_serve/*filename' => 'open_access_publications#file_serve', as: :scholarsphere_file_serve, constraints: { filename: /.*/ }
    patch 'publications/:id/open_access' => 'open_access_publications#update', as: :open_access_publication
    post 'publications/:id/open_access/scholarsphere_deposit' => 'open_access_publications#create_scholarsphere_deposit', as: :scholarsphere_deposit
    get 'publications/:id/open_access/waivers/new' => 'internal_publication_waivers#new', as: :new_internal_publication_waiver
    post 'publications/:id/open_access/waivers' => 'internal_publication_waivers#create', as: :internal_publication_waivers
    get 'publications/open_access_waivers/new' => 'external_publication_waivers#new', as: :new_external_publication_waiver
    post 'publications/open_access_waivers' => 'external_publication_waivers#create', as: :external_publication_waivers
    post 'unbecome/:user_id' => 'masquerade#unbecome', as: :unbecomes_user
    post 'become/:user_id' => 'masquerade#become', as: :becomes_user
  end

  post 'orcid_access_token' => 'orcid_access_tokens#new', as: :new_orcid_access_token
  get 'orcid_access_token' => 'orcid_access_tokens#create', as: :orcid_access_token

  get 'proxies' => 'deputy_assignments#index', as: :deputy_assignments
  post 'proxies' => 'deputy_assignments#create'
  patch 'proxies/:id/confirm' => 'deputy_assignments#confirm', as: :confirm_deputy_assignment
  delete 'proxies/:id' => 'deputy_assignments#destroy', as: :deputy_assignment

  post 'authorships' => 'authorships#create', as: :authorships
  put 'authorships/sort' => 'authorships#sort'
  put 'authorships/:id' => 'authorships#update', as: :authorship

  put 'presentation_contributions/sort' => 'presentation_contributions#sort'
  put 'presentation_contributions/:id' => 'presentation_contributions#update', as: :presentation_contribution

  put 'user_performances/sort' => 'user_performances#sort'
  put 'user_performances/:id' => 'user_performances#update', as: :user_performance
end
