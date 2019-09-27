Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount SwaggerUiEngine::Engine, at: "/api_docs"

  devise_for :users

  post 'admin/user/:user_id/duplicate_publication_groupings' => 'custom_admin/duplicate_publication_groupings#create', as: :admin_user_duplicate_publication_groupings
  post 'admin/duplicate_publication_group/:duplicate_publication_group_id/merge' => 'custom_admin/publication_merges#create', as: :admin_duplicate_publication_group_merge

  get '/user/sign_in' => 'user/sessions#new', as: :new_user_session
  match '/user/sign_out', to: 'user/sessions#destroy', via: [:get, :delete], as: :destroy_user_session

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

  put 'authorships/sort' => 'authorships#sort'
  put 'authorships/:id' => 'authorships#update', as: :authorship

  put 'presentation_contributions/sort' => 'presentation_contributions#sort'
  put 'presentation_contributions/:id' => 'presentation_contributions#update', as: :presentation_contribution

  put 'user_performances/sort' => 'user_performances#sort'
  put 'user_performances/:id' => 'user_performances#update', as: :user_performance
end
