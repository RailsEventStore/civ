event_store = Rails.configuration.event_store
service = Game::Service.new(event_store)
game_id = SecureRandom.uuid
host_game_command = Game::HostGame.new(game_id, 24.hours)
service.host_game(host_game_command)
game_read_model = ReadModel::Game.find(game_id)
game_read_model.name = "arkency2"
game_read_model.save

Player.create!(steam_name: "swistak35", slack_name: "swistak")
Player.create!(steam_name: "jura55", slack_name: "jorgen")
Player.create!(steam_name: "halkye", slack_name: "halki")
Player.create!(steam_name: "The Rubyist", slack_name: "pkondzior")

[ {slack_name: "swistak", slot_id: 0}, {slack_name: "jorgen", slot_id: 1},
  {slack_name: "halki", slot_id: 2}, {slack_name: "dysk", slot_id: 3},
  {slack_name: "pkondzior", slot_id: 7} ].each do |player_data|
  player = Player.find_by(slack_name: player_data[:slack_name])
  command = Game::RegisterPlayer.new(game_id, player.id, player_data[:slot_id])
  service.register_player(command)
end
