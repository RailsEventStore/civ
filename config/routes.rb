Rails.application.routes.draw do
  root(to: "root#welcome")

  resources(:games, only: %i[show])
  post("/games/say", to: "games#say")
  resources(:players)
  resources(:pitboss_entries, only: %i[create index])
  resources(:player_stats, only: "index")
end
