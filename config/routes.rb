Rails.application.routes.draw do
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
end
