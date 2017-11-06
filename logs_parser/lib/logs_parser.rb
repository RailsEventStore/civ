require "net/http"

module LogsParser
    class Service

    Result = Struct.new(:game_name, :entry_type, :data, :timestamp)

    def initialize(game_name, players_count)
      @game_name     = game_name
      @players_count = players_count
    end

    def call(line)
      if contains_relevant_data?(line)
        parts, timestamp = split_log_line(line)
        if new_turn_started?(line)
          return Result.new(game_name, "NewTurnStarted", parts.last, timestamp)
        elsif player_ended_turn?(line)
          player_number = parts[8].gsub(",", "")
          if player_number.match(/\d/) && player_number.to_i < players_count
            return Result.new(game_name, "PlayerEndedTurn", player_number, timestamp)
          end
        elsif player_end_turn_cancelled?(line)
          return Result.new(game_name, "PlayerEndTurnCancelled", parts[8], timestamp)
        elsif player_connected?(line)
          player_number = line.scan(/\d/)[-3]
          if player_number.to_i < players_count
            return Result.new(game_name, "PlayerConnected", player_number, timestamp)
          end
        elsif player_disconnected?(line)
          player_number = line.scan(/\d/)[-1]
          return Result.new(game_name, "PlayerDisconnected", player_number, timestamp)
        end
      end
    end

    private

    attr_reader :game_name, :players_count

    def contains_relevant_data?(line)
      line.match(/DBG: Game Turn/)     ||
        line.match(/:NetTurnComplete/) ||
        line.match(/NetTurnUnready/)   ||
        line.match(/NetPlayerReady/)   ||
        line.match(/ConnectionClosed Player\(\d\)/)
    end

    def split_log_line(line)
      parts = line.split
      timestamp = parts.first.gsub(/(\[|\])/, "")
      [parts, timestamp]
    end

    def new_turn_started?(line)
      line.match(/DBG: Game Turn/)
    end

    def player_ended_turn?(line)
      line.match(/NetTurnComplete/)
    end

    def player_end_turn_cancelled?(line)
      line.match(/NetTurnUnready/)
    end

    def player_connected?(line)
      line.match(/NetPlayerReady/)
    end

    def player_disconnected?(line)
      line.match(/ConnectionClosed/)
    end
  end

  class HttpAdapter
    NetworkError = Class.new(StandardError)
    ServerError  = Class.new(StandardError)

    def initialize(host:)
      @http = Net::HTTP.new(host)
    end

    def send_data(payload)
      request = Net::HTTP::Post.new("/pitboss_entries")
      request.set_form_data({
        "pitboss_entry[game_name]"  => payload.game_name,
        "pitboss_entry[value]"      => payload.data,
        "pitboss_entry[entry_type]" => payload.entry_type,
        "pitboss_entry[timestamp]"  => payload.timestamp})
      response = http.request(request)
      unless response.code_type == Net::HTTPNoContent
        raise ServerError, response.code
      end
      return response
    rescue Timeout::Error, EOFError, Errno::EINVAL,
      Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::ECONNREFUSED,
      Errno::EHOSTUNREACH, SocketError, Net::ProtocolError => e
        raise NetworkError, e.message
    end

    private

    attr_reader :http
  end
end
