# PitbossStats

## Usage

### Web app

#### Game setup

##### host game:

```ruby
event_store = Rails.configuration.event_store
service = Game::Service.new(event_store)
game_id = SecureRandom.uuid
host_game_command = Game::HostGame.new(game_id, 24.hours)
service.host_game(host_game_command)
```

##### rename game and add slack data:

```ruby
game_read_model = ReadModel::GameReadModel.find(game_id)
game_read_model.name = "arkency2"
slack_token = "your-token"
slack_channel = "your-game-channel"
ip_address = "your-game-ip-address"
game_read_model.save
```

##### create players

```ruby
Player.create!(steam_name: "swistak35", slack_name: "swistak")
Player.create!(steam_name: "jura55", slack_name: "jorgen")
Player.create!(steam_name: "halkye", slack_name: "halki")
Player.create!(steam_name: "The Rubyist", slack_name: "pkondzior")
```

##### register players in correct order

```ruby
["halkye", "tango_mig", "pan_sarin", "swistak35", "The Rubyist", "jura55", "jamesworthy", "dysk"].each_with_index do |steam_name, index|
  player = Player.find_by(steam_name: steam_name)
  command = Game::RegisterPlayer.new(game_id, player.id, index)
  service.register_player(command)
end
```

##### unregister players in case they are no longer playing

```ruby
event_store = Rails.configuration.event_store
service = Game::Service.new(event_store)
command = Game::UnregisterPlayer.new("189e3f21-27c7-431b-9025-1feb92697635", Player.find_by(steam_name: "halkye").id, 2)
service.unregister_player(command)
```

### Game server

#### change game config to enabled logging
#### download parser:

* [Script](https://github.com/dysk/pitboss-stats/blob/master/script/pbs3.rb)
* [Parser lib](https://github.com/dysk/pitboss-stats/blob/master/logs_parser/lib/logs_parser.rb)

and place in Logs directory

#### make sure you have ruby installed

You can use [Ruby installer](https://rubyinstaller.org/)

#### run from command line

`ruby pbs3.rb [game_uuid] [players_count]`

##### in case of game crash use

[Afer crash script](https://github.com/dysk/pitboss-stats/blob/master/script/after_crash.rb)

to reset current turn, turn time and players end turn status
