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
        maybe_notify_remainging_players(event)
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
      client = Slack::Web::Client.new(token: game.slack_token)
      client.chat_postMessage(channel: game.slack_channel, text: game.build_slack_new_turn_message(event.data), as_user: false, icon_url: gandhi_url)
    end

    def maybe_notify_remainging_players(event)
      game = ReadModel::GameReadModel.find_by(id: event.data[:game_id])
      return unless game && game.slack_token
      current_turn = Game::CurrentTurn.new(event_store).call("Game$#{event.data[:game_id]}")
      if current_turn.unfinished_player_ids.size <= game.number_of_remaining_players_to_notify
        remaining_players_mentions = Player.where(id: current_turn.unfinished_player_ids).map do |player|
          "<@#{player.slack_name}>"
        end.join(" ")
        client = Slack::Web::Client.new(token: game.slack_token)
        response = client.chat_postMessage(channel: game.slack_channel, text: "Turn " + remaining_players_mentions, as_user: false, icon_url: gandhi_url)
        logger.warn("Slack response: #{response.pretty_inspect}") if logger
      end
    end

    def gandhi_url
      "https://vignette.wikia.nocookie.net/civilization/images/3/36/Gandhi_%28Civ5%29.png/revision/latest?cb=20121104232443"
    end

    attr_reader :logger, :event_store
  end
end
