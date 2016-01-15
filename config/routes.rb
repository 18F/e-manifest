Rails.application.routes.draw do
  root to: 'manifests#index'

  resources :manifests, only: [:new, :create, :show] do
    resources :sign_or_upload, only: [:new]
    resources :manifest_uploads, only: [:new, :create]
  end

  resources :manifest_uploads, only: [:new, :create]
  resources :submissions, only: [:new]

  namespace :api do
    namespace :v0 do
      resources :tokens, only: [:create]
      resources :manifests, only: [] do
        resource :signature, only: [:create]
      end
      resources :manifests, only: [:create]
      resources :method_codes, only: [:index]
      patch 'manifests', to: 'manifests#update'
      get 'manifest', to: 'manifests#show'
      get 'manifests/search', to: 'manifests#search'
    end
  end

  require 'sidekiq/web'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end

  mount Sidekiq::Web => '/sidekiq'
end
