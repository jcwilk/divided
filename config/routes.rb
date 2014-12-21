Divided::Application.routes.draw do
  resources :tests, only: :show

  resources :turns, only: [:create]

  root to: 'client#new'

  mount DV::Root => '/dv'
  #root to: 'chat#index'
end
