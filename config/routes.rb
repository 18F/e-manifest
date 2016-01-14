Rails.application.routes.draw do
  root to: 'manifests#index'
  resources :manifests, only: [:new, :create]
  resources :manifest_uploads, only: [:new]
  resources :submissions, only: [:new]

  get 'api-examples', to: 'api_documentation#examples'
  get 'api-diagnostics', to: 'api_documentation#diagnostics'
  get 'api-documentation', to: 'api_documentation#swagger'

  namespace :api do
    namespace :v0 do
      resources :tokens, only: [:create]
      resources :manifests, only: [] do
        resource :signature, only: [:create]
      end
      resources :manifests, only: [:create]
      resources :method_codes, only: [:index]
      patch 'manifests/:id', to: 'manifests#update'
      put 'manifests/:id', to: 'manifests#update'
      get 'manifests/search', to: 'manifests#search'
      get 'manifests/:id', to: 'manifests#show'
    end
  end

  require 'sidekiq/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end

  mount Sidekiq::Web => '/sidekiq'
end
