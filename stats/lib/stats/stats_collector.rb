module Stats
  class StatsCollector
    def initialize(logger: nil, event_store:)
      @event_store = event_store
    end

    def call(event)
      current_turn = Game::CurrentTurn.new(event_store).call("Game$#{event.data[:game_id]}")
      player_ids = current_turn.unfinished_player_ids
      game_id = event.data[:game_id]
      return if player_ids.empty?
      case event
      when Game::NewTurnStarted
        increment_players_turn_counters(player_ids, game_id)
      when Game::PlayerDisconnected
        maybe_increment_last_player_counter(player_ids, game_id, current_turn.turn)
      end

    rescue => e
      error_message = "Error in Stats::StatsCollector: #{e.inspect}"
      logger.warn(error_message) if logger
      raise if Rails.env.test?
    end

    private

    def increment_players_turn_counters(player_ids, game_id)
      player_ids.each do |player_id|
        ReadModel::PlayerStat
          .find_or_initialize_by(player_id: player_id, game_id: "all")
          .tap do |stat_read_model|
            stat_read_model.turns_taken += 1
            stat_read_model.save!
          end
      end

      player_ids.each do |player_id|
        ReadModel::PlayerStat
          .find_or_initialize_by(player_id: player_id, game_id: game_id)
          .tap do |stat_read_model|
            stat_read_model.turns_taken += 1
            stat_read_model.save!
          end
      end
    end

    def maybe_increment_last_player_counter(player_ids, game_id, turn_number)
      return unless player_ids.size == 1
      return if alread_incremented?(game_id, turn_number)

      ReadModel::PlayerStat
        .find_or_initialize_by(player_id: player_ids.first, game_id: "all")
        .tap do |stat_read_model|
          stat_read_model.turns_last += 1
          stat_read_model.save!
        end

      ReadModel::PlayerStat
        .find_or_initialize_by(player_id: player_ids.first, game_id: game_id)
        .tap do |stat_read_model|
          stat_read_model.turns_last += 1
          stat_read_model.save!
        end

      publish_slothfulness_increased(game_id, turn_number)
    end

    def alread_incremented?(game_id, turn_number)
      event_store
        .read
        .stream("Slothfulness$#{game_id}")
        .of_type([Game::PlayerSlotfhulnessIncreased])
        .to_a
        .any? { |event| event.data.fetch(:turn_number) == turn_number }
    end

    def publish_slothfulness_increased(game_id, turn_number)
      event_store.publish(
        Game::PlayerSlotfhulnessIncreased.new(data: {game_id: game_id, turn_number: turn_number}),
        stream_name: "Slothfulness$#{game_id}"
      )
    end

    attr_reader :event_store
  end
end
