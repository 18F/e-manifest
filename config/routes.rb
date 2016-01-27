Rails.application.routes.draw do
  root to: 'manifests#index'
  resources :manifests, only: [:new, :create, :show, :index]

  resources :manifests, only: [:show] do
    resources :sign_or_upload, only: [:new]
    resources :manifest_uploads, only: [:new, :create, :show]
    resources :signatures, only: [:new, :create]
    get 'signature', to: 'signatures#show'
    resources :tokens, only: [:new, :create]
  end

  resources :manifest_uploads, only: [:new, :create]
  resources :submissions, only: [:new]

  get 'api-examples', to: 'api_documentation#examples'
  get 'api-diagnostics', to: 'api_documentation#diagnostics'
  get 'api-documentation', to: 'api_documentation#swagger'

  namespace :api do
    namespace :v0 do
      resources :tokens, only: [:create]
      get 'manifests/search', to: 'manifests#search'
      post 'manifests/validate', to: 'manifests#validate'
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
