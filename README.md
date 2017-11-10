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

##### rename game:

```ruby
game_read_model = ReadModel::Game.find(game_id)
game_read_model.name = "arkency2"
game_read_model.save
```

##### create players

```ruby
Player.create!(steam_name: "swistak35", slack_name: "swistak")
Player.create!(steam_name: "jura55", slack_name: "jorgen")
Player.create!(steam_name: "halkye", slack_name: "halki")
Player.create!(steam_name: "The Rubyist", slack_name: "pkondzior")
```

##### register players

```ruby
[ {slack_name: "swistak", slot_id: 0}, {slack_name: "jorgen", slot_id: 1},
  {slack_name: "halki", slot_id: 2}, {slack_name: "dysk", slot_id: 3},
  {slack_name: "pkondzior", slot_id: 7} ].each do |player_data|
  player = Player.find_by(slack_name: player_data[:slack_name])
  command = Game::RegisterPlayer.new(game_id, player.id, player_data[:slot_id])
  service.register_player(command)
end
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
