Rails.application.routes.draw do

  root to: 'public#home'

  scope module: 'api' do
    namespace :v1 do
      resources :publications
    end
  end
end
