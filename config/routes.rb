FayeRailsDemo::Application.routes.draw do
  resources :tests, only: :show

  resources :turns, only: [:index,:create]

  root to: 'client#new'
  #root to: 'chat#index'
end
