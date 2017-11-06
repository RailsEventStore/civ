require "net/http"
require_relative "service"

def send_data(game_name:, value:, entry_type:, timestamp:)
  http = Net::HTTP.new("fierce-reaches-40697.herokuapp.com")

  request = Net::HTTP::Post.new("/pitboss_entries")
  request.set_form_data({
    "pitboss_entry[game_name]" => game_name,
    "pitboss_entry[value]" => value,
    "pitboss_entry[entry_type]" => entry_type,
    "pitboss_entry[timestamp]" => timestamp})
  response = http.request(request)
  puts response.inspect
end

game_name = ARGV[0]
players_count = ARGV[1].to_i
last_line_read = ARGV[2].to_i || 0
parser = LogsParser::Service.new(game_name, players_count)

iterations_counter = 0
loop do
  puts "Iteration #{iterations_counter}"
  puts "Processing log file from line #{last_line_read}..."
  lines_counter = 0
  previous_last_line_read = last_line_read
  IO.foreach("net_message_debug.log") do |line|
    if result = parser.call(line)
      send_data(
        game_name:  result.game_name,
        value:      result.data,
        entry_type: result.entry_type,
        timestamp:  result.timestamp
      )
    end

    lines_counter += 1
    last_line_read = lines_counter
  end
  iterations_counter += 1
  sleep 60
end
