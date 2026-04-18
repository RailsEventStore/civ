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
      when Game::CityFounded
        notify_game_event(event, "A new city has been founded in far away land")
      when Game::WarStatusChanged
        notify_game_event(event, "War status has changed in far away land")
      when Game::CityConquered
        notify_game_event(event, city_conquered_message(event))
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
      return if current_turn.unfinished_player_ids.size == 0
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
      game = ReadModel::GameReadModel.find_by(id: event.data[:game_id])
      return unless game && game.slack_token
      player_id = game.registered_slots&.dig(event.data[:slot])
      player = Player.find_by(id: player_id) if player_id
      CustomSlackClient.post_message(
        channel: game.slack_channel,
        text: game.build_slack_timer_reset_message(event.data, player),
        token: game.slack_token
      )
    end

    def city_conquered_message(event)
      case event.data[:action]
      when "puppeted" then "A city has been puppeted in far away land"
      when "annexed" then "A city has been annexed in far away land"
      when "razing_started" then "A city is being razed in far away land"
      else "A city has been conquered in far away land"
      end
    end

    def notify_game_event(event, message)
      game = ReadModel::GameReadModel.find_by(id: event.data[:game_id])
      return unless game && game.slack_token
      CustomSlackClient.post_message(
        channel: game.slack_channel,
        text: message,
        token: game.slack_token
      )
    end

    attr_reader :logger, :event_store
  end
end
