require "net/http"
require_relative "logs_parser"

game_name      = ARGV[0]
players_count  = ARGV[1].to_i
last_line_read = ARGV[2].to_i || 0
host           = ARGV[3] || "fierce-reaches-40697.herokuapp.com"
parser       = LogsParser::Service.new(game_name, players_count)
http_adapter = LogsParser::HttpAdapter.new(host: host)

iterations_counter = 0
loop do
  puts "Iteration #{iterations_counter}"
  puts "Processing log file from line #{last_line_read}..."
  lines_counter = 0
  previous_last_line_read = last_line_read
  IO.foreach("net_message_debug.log") do |line|
    if lines_counter >= previous_last_line_read
      if result = parser.call(line)
        response = http_adapter.send_data(result)
        puts response.inspect
      end
    end

    lines_counter += 1
    last_line_read = lines_counter
  end
  iterations_counter += 1
  sleep 60
end
