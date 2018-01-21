module Notifications
  class SlackNotifier
    def initialize(logger: nil)
      @logger = logger
    end

    def call(event)
      case event
      when Game::NewTurnStarted
        new_turn_notification(event)
      end
    rescue => e
      error_message = "Error in Notifications::SlackNotifier: #{e.inspect}"
      logger.warn(error_message) if logger
      raise if Rails.env.test?
    end

    private

    def new_turn_notification(event)
      game = ReadModel::GameReadModel.find(event.data[:game_id])
      client = Slack::Web::Client.new(token: game.slack_token)
      client.chat_postMessage(channel: game.slack_channel, text: game.build_slack_new_turn_message(event.data), as_user: true)
    end

    attr_reader :logger
  end
end
