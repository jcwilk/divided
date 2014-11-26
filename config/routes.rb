FayeRailsDemo::Application.routes.draw do
  resources :tests, only: :show

  resources :turns, only: [:create]

  root to: 'client#new'
  #root to: 'chat#index'
end
