Rails.application.routes.draw do
  resources :players
  root to: 'home#index'

  resources :pitboss_entries, only: [:create, :index]
end
