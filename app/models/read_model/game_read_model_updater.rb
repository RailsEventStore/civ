module ReadModel
  class GameReadModelUpdater
    def initialize(logger: nil)
      @logger = logger
    end

    def call(event)
      ApplicationRecord.transaction do
        read_model = ReadModel::GameReadModel.lock(true).find_or_initialize_by(id: event.data[:game_id])
        case event
        when Game::PlayerRegistered
          read_model.registered_slots[event.data.fetch(:slot_id)] = event.data.fetch(:player_id)
          read_model.player_ids << event.data.fetch(:player_id)
        when Game::PlayerUnregistered
          removed_player_id = read_model.registered_slots.delete(event.data.fetch(:slot_id).to_s)
          read_model.unfinished_player_ids.delete(removed_player_id)
        when Game::NewTurnStarted
          started_at = event.metadata.fetch(:timestamp)
          read_model.current_turn[:started_at] = started_at
          read_model.current_turn[:number] = event.data.fetch(:turn)
          read_model.current_turn[:ends_at] = started_at + read_model.current_turn.fetch(:timer, 24.hours)
          read_model.unfinished_player_ids = read_model.registered_slots.values
        when Game::PlayerEndedTurn
          player_id = read_model.registered_slots[event.data.fetch(:slot).to_s]
          read_model.unfinished_player_ids.delete(player_id)
        when Game::PlayerEndTurnCancelled, Game::PlayerConnected
          player_id = read_model.registered_slots[event.data.fetch(:slot).to_s]
          read_model.unfinished_player_ids << player_id
          read_model.unfinished_player_ids.uniq!
        end

        read_model.save!
      end

    rescue => e
      error_message = "Error in ReadModel::GameReadModelUpdater: #{e.inspect}"
      @logger.warn(error_message) if @logger
      raise if Rails.env.test?
    end
  end
end
