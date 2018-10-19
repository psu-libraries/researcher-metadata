Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount SwaggerUiEngine::Engine, at: "/api_docs"

  devise_for :users

  post 'admin/user/:user_id/duplicate_publication_groupings' => 'custom_admin/duplicate_publication_groupings#create', as: :admin_user_duplicate_publication_groupings
  post 'admin/duplicate_publication_group/:duplicate_publication_group_id/merge' => 'custom_admin/publication_merges#create', as: :admin_duplicate_publication_group_merge

  get '/user/sign_in' => 'user/sessions#new', as: :new_user_session
  match '/user/sign_out', to: 'user/sessions#destroy', via: [:get, :delete], as: :destroy_user_session

  root to: 'public#home'

  scope module: 'api' do
    namespace :v1 do
      resources :publications
      get 'users/:webaccess_id/publications' => 'users#publications', as: :user_publications
      get 'users/:webaccess_id/contracts' => 'users#contracts', as: :user_contracts
      post 'users/publications' => 'users#users_publications', as: :users_publications
      get 'users/:webaccess_id/etds' => 'users#etds', as: :user_etds
      get 'users/:webaccess_id/presentations' => 'users#presentations', as: :user_presentations
    end
  end
end
