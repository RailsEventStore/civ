module Stats
  class StatsCollector
    def initialize(logger: nil, event_store:)
      @event_store = event_store
    end

    def call(event)
      current_turn = Game::CurrentTurn.new(event_store).call("Game$#{event.data[:game_id]}")
      player_ids = current_turn.unfinished_player_ids
      return if player_ids.empty?
      case event
      when Game::NewTurnStarted
        increment_players_turn_counters(player_ids)
      when Game::PlayerDisconnected
        maybe_increment_last_player_counter(player_ids)
      end
    rescue => e
      error_message = "Error in Stats::StatsCollector: #{e.inspect}"
      logger.warn(error_message) if logger
      raise if Rails.env.test?
    end

    private

    def increment_players_turn_counters(player_ids)
      player_ids.each do |player_id|
        ReadModel::PlayerStat.find_or_initialize_by(player_id: player_id).tap do |stat_read_model|
          stat_read_model.turns_taken += 1
          stat_read_model.save!
        end
      end
    end

    def maybe_increment_last_player_counter(player_ids)
      return unless player_ids.size == 1
      ReadModel::PlayerStat.find_or_initialize_by(player_id: player_ids.first).tap do |stat_read_model|
        stat_read_model.turns_last += 1
        stat_read_model.save!
      end
    end

    attr_reader :event_store
  end
end
