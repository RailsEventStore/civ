#host game
event_store = Rails.configuration.event_store
service = Game::Service.new(event_store)
game_id = SecureRandom.uuid
host_game_command = Game::HostGame.new(game_id, 24.hours)
service.host_game(host_game_command)
game_read_model = ReadModel::Game.find(game_id)
game_read_model.name = "arkency1"
game_read_model.save

#create players
Player.create!(steam_name: "swistak35", slack_name: "swistak")
Player.create!(steam_name: "jura55", slack_name: "jorgen")
Player.create!(steam_name: "halkye", slack_name: "halki")
Player.create!(steam_name: "The Rubyist", slack_name: "samsonmiodek")

#register players
["halkye", "tango_mig", "pan_sarin", "swistak35", "The Rubyist", "jura55", "jamesworthy", "dysk"].each_with_index do |steam_name, index|
  player = Player.find_by(steam_name: steam_name)
  command = Game::RegisterPlayer.new(game_id, player.id, index)
  service.register_player(command)
end
