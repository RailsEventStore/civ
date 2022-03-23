require "net/http"

def contains_relevant_data?(line)
  line.match(/DBG: Game Turn/) || line.match(/NetTurnComplete/) || line.match(/NetTurnUnready/) ||
    line.match(/NetPlayerReady/) || line.match(/ConnectionClosed Player\(\d\)/)
end

def send_data(game_name:, value:, entry_type:, timestamp:)
  http = Net::HTTP.new("fierce-reaches-40697.herokuapp.com")

  request = Net::HTTP::Post.new("/pitboss_entries")
  request.set_form_data(
    {
      "pitboss_entry[game_name]" => game_name,
      "pitboss_entry[value]" => value,
      "pitboss_entry[entry_type]" => entry_type,
      "pitboss_entry[timestamp]" => timestamp
    }
  )
  response = http.request(request)
  puts response.inspect
end

game_name = ARGV[0]
players_count = ARGV[1].to_i

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
      timestamp = parts.first.gsub(/(\[|\])/, "")
      if line.match(/DBG: Game Turn/)
        send_data(game_name: game_name, value: parts.last, entry_type: "NewTurnStarted", timestamp: timestamp)
      elsif line.match(/NetTurnComplete/)
        player_number = parts[8].gsub(",", "")
        if player_number.match(/\d/) && player_number.length == 1 && player_number.to_i < players_count
          send_data(game_name: game_name, value: player_number, entry_type: "PlayerEndedTurn", timestamp: timestamp)
        end
      elsif line.match(/NetTurnUnready/)
        send_data(game_name: game_name, value: parts[8], entry_type: "PlayerEndTurnCancelled", timestamp: timestamp)
      elsif line.match(/NetPlayerReady/)
        player_number = line.scan(/\d/)[-3]
        if player_number.to_i < players_count
          send_data(game_name: game_name, value: player_number, entry_type: "PlayerConnected", timestamp: timestamp)
        end
      elsif line.match(/ConnectionClosed/)
        player_number = line.scan(/\d/)[-1]
        send_data(game_name: game_name, value: player_number, entry_type: "PlayerDisconnected", timestamp: timestamp)
      end
    end
    lines_counter += 1
    last_line_read = lines_counter
  end
  iterations_counter += 1
  sleep 60
end
