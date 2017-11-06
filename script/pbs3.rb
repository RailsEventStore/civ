require "net/http"
require_relative "logs_parser"

game_name      = ARGV[0]
players_count  = ARGV[1].to_i
host           = ARGV[2]
last_line_read = ARGV[3].to_i || 0
parser       = LogsParser::Service.new(game_name, players_count)
http_adapter = LogsParser::HttpAdapter.new(host)

iterations_counter = 0
loop do
  puts "Iteration #{iterations_counter}"
  puts "Processing log file from line #{last_line_read}..."
  lines_counter = 0
  previous_last_line_read = last_line_read
  IO.foreach("net_message_debug.log") do |line|
    if result = parser.call(line)
      response = http_adapter.send_data(result)
      puts response.inspect
    end

    lines_counter += 1
    last_line_read = lines_counter
  end
  iterations_counter += 1
  sleep 60
end
