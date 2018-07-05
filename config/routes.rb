Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount SwaggerUiEngine::Engine, at: "/api_docs"

  devise_for :users

  get '/user/sign_in' => 'user/sessions#new', as: :new_user_session
  match '/user/sign_out', to: 'user/sessions#destroy', via: [:get, :delete], as: :destroy_user_session

  root to: 'public#home'

  scope module: 'api' do
    namespace :v1 do
      resources :publications
    end
  end
end
