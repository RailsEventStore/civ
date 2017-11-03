require "net/http"

def contains_relevant_data?(line)
  line.match(/DBG: Game Turn/) || line.match(/PlayerEnededTurn/) || line.match(/NetTurnUnready/)
end

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
iterations_counter = 0
last_line_read = 0
loop do
  puts "Iteration #{iterations_counter}"
  puts "Processing log file from line #{last_line_read}..."
  lines_counter = 0
  previous_last_line_read = last_line_read
  IO.foreach("net_message_debug.log") do |line|
    if lines_counter >= previous_last_line_read && contains_relevant_data?(line)
      puts line
      parts = line.split
      if line.match(/DBG: Game Turn/)
        send_data(game_name: game_name, value: parts.last, entry_type: "NewTurn", timestamp: parts.first.gsub(/(\[|\])/, ""))
      elsif line.match(/NetTurnComplete/)
        send_data(game_name: game_name, value: parts[8].last.gsub(",", ""), entry_type: "PlayerEnededTurn", timestamp: parts.first.gsub(/(\[|\])/, ""))
      elsif line.match(/NetTurnUnready/)
        send_data(game_name: game_name, value: parts[8].last, entry_type: "PlayerEndTurnCancelled", timestamp: parts.first.gsub(/(\[|\])/, ""))
      end
    end
    lines_counter += 1
    last_line_read = lines_counter
  end
  iterations_counter += 1
  sleep 60
end
