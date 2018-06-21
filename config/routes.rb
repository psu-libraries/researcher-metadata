Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root to: 'public#home'

  scope module: 'api' do
    namespace :v1 do
      resources :publications
    end
  end
end
