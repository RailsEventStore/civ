Rails.application.routes.draw do
  root to: "root#welcome"

  resources :games
  resources :players
  resources :pitboss_entries, only: %i[create index]
end
