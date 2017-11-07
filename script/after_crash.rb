require_relative "logs_parser/lib/logs_parser"
game_name = ARGV[0]
players_count ARGV[1]
turn_number = ARGV[2]
last_timestamp = ARGV[3]
host = ARGV[4] || "fierce-reaches-40697.herokuapp.com"

http_adapter = LogsParser::HttpAdapter.new(host: host)
payload = LogsParser::Service::Result.new(game_name, "NewTurnStarted", turn_number, last_timestamp)

http_adapter.send_data(payload)

(0..players_count - 1).each do |player_number|
  payload = LogsParser::Service::Result.new(game_name, "PlayerEndTurnCancelled", "#{player_number}", last_timestamp)
  http_adapter.send_data(payload)
end
