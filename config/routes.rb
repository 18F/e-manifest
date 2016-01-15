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
      get 'manifests/search', to: 'manifests#search'
      resources :manifests, only: [:create, :show, :update] do
        resource :signature, only: [:create]
      end
      resources :method_codes, only: [:index]
    end
  end

  require 'sidekiq/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end

  mount Sidekiq::Web => '/sidekiq'
end
