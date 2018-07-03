Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount SwaggerUiEngine::Engine, at: "/api_docs"

  root to: 'public#home'

  scope module: 'api' do
    namespace :v1 do
      resources :publications
    end
  end
end
