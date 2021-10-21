# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount SwaggerUiEngine::Engine, at: '/api_docs'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    match 'sign_out', to: 'devise/sessions#destroy', via: [:get, :delete], as: :destroy_user_session
  end

  namespace :admin do
    post 'user/:user_id/duplicate_publication_groupings' => 'duplicate_publication_groupings#create', as: :user_duplicate_publication_groupings
    post 'duplicate_publication_group/:duplicate_publication_group_id/merge' => 'publication_merges#create', as: :duplicate_publication_group_merge
    delete 'duplicate_publication_group/:id' => 'duplicate_publication_groups#delete', as: :duplicate_publication_group
    post 'external_publication_waivers/:external_publication_waiver_id/link' => 'publication_waiver_links#create', as: :publication_waiver_link
  end

  root to: 'public#home'
  get '/resources' => 'public#resources', as: :resources

  scope module: 'api' do
    namespace :v1 do
      get 'publications' => 'publications#index', as: :publications
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
  get 'profile/publications/edit' => 'profiles#edit_publications', as: :edit_profile_publications
  get 'profile/presentations/edit' => 'profiles#edit_presentations', as: :edit_profile_presentations
  get 'profile/performances/edit' => 'profiles#edit_performances', as: :edit_profile_performances
  get 'profile/other_publications/edit' => 'profiles#edit_other_publications', as: :edit_profile_other_publications
  get 'profile/bio' => 'profiles#bio', as: :profile_bio
  post 'profile/bio/orcid/employments/:membership_id' => 'orcid_employments#create', as: :orcid_employments
  post 'profile/bio/orcid/works' => 'orcid_works#create', as: :orcid_works
  get 'profile/publications/:id/open_access/edit' => 'open_access_publications#edit', as: :edit_open_access_publication
  patch 'profile/publications/:id/open_access' => 'open_access_publications#update', as: :open_access_publication
  post 'profile/publications/:id/open_access/scholarsphere_deposit' => 'open_access_publications#create_scholarsphere_deposit', as: :scholarsphere_deposit
  get 'profile/publications/:id/open_access/waivers/new' => 'internal_publication_waivers#new', as: :new_internal_publication_waiver
  post 'profile/publications/:id/open_access/waivers' => 'internal_publication_waivers#create', as: :internal_publication_waivers
  get 'profile/publications/open_access_waivers/new' => 'external_publication_waivers#new', as: :new_external_publication_waiver
  post 'profile/publications/open_access_waivers' => 'external_publication_waivers#create', as: :external_publication_waivers
  post 'orcid_access_token' => 'orcid_access_tokens#new', as: :new_orcid_access_token
  get 'orcid_access_token' => 'orcid_access_tokens#create', as: :orcid_access_token

  get 'profile' => redirect('profile/publications/edit')

  put 'authorships/sort' => 'authorships#sort'
  put 'authorships/:id' => 'authorships#update', as: :authorship

  put 'presentation_contributions/sort' => 'presentation_contributions#sort'
  put 'presentation_contributions/:id' => 'presentation_contributions#update', as: :presentation_contribution

  put 'user_performances/sort' => 'user_performances#sort'
  put 'user_performances/:id' => 'user_performances#update', as: :user_performance
end
