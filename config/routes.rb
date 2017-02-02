Rails.application.routes.draw do
  # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  namespace :api do
    namespace :v1 do
      post 'login' => 'authentication#authenticate_user'
      resources :users, only: [:show]
      post 'users/new' => 'users#create'
      resources :search, only: [:index]
    end
  end

  get 'home' => 'home#index'
  get 'docs', to: redirect('/swagger/dist/index.html?url=/api/documentation/api-docs.json')
end
