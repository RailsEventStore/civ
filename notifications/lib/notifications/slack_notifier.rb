require 'custom_slack_client'

module Notifications
  class SlackNotifier
    def initialize(logger: nil, event_store:)
      @logger = logger
      @event_store = event_store
    end

    def call(event)
      case event
      when Game::NewTurnStarted
        new_turn_notification(event)
      when Game::PlayerDisconnected
        maybe_notify_remaining_players(event)
      when Game::TimerReset
        notify_about_timer_reset(event)
      end
    rescue => e
      error_message = "Error in Notifications::SlackNotifier: #{e.inspect}"
      logger.warn(error_message) if logger
      raise if Rails.env.test?
    end

    private

    def new_turn_notification(event)
      game = ReadModel::GameReadModel.find_by(id: event.data[:game_id])
      return unless game && game.slack_token
      CustomSlackClient.post_message(
        channel: game.slack_channel,
        text: game.build_slack_new_turn_message(event.data),
        token: game.slack_token
      )
    end

    def maybe_notify_remaining_players(event)
      game = ReadModel::GameReadModel.find_by(id: event.data[:game_id])
      return unless game && game.slack_token
      current_turn = Game::CurrentTurn.new(event_store).call("Game$#{event.data[:game_id]}")
      if current_turn.unfinished_player_ids.size <= game.number_of_remaining_players_to_notify
        remaining_players_mentions =
          Player.where(id: current_turn.unfinished_player_ids).map { |player| "<@#{player.slack_id}>" }.join(" ")
        CustomSlackClient.post_message(
          channel: game.slack_channel,
          text: "Turn " + remaining_players_mentions,
          token: game.slack_token
        )
      end
    end

    def notify_about_timer_reset(event)
      puts "=== NOTIFY_ABOUT_TIMER_RESET DEBUG ==="
      game = ReadModel::GameReadModel.find_by(id: event.data[:game_id])
      puts "Game found: #{!!game}"
      puts "Game slack_token present: #{game&.slack_token&.present?}"
      return unless game && game.slack_token
      player_id = game.registered_slots&.dig(event.data[:slot])
      puts "Player ID from registered_slots: #{player_id}"
      player = Player.find_by(id: player_id) if player_id
      puts "Player found: #{!!player}"
      puts "About to call CustomSlackClient.post_message"
      CustomSlackClient.post_message(
        channel: game.slack_channel,
        text: game.build_slack_timer_reset_message(event.data, player),
        token: game.slack_token
      )
      puts "CustomSlackClient.post_message called successfully"
    end

    attr_reader :logger, :event_store
  end
end
