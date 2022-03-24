ENV["RAILS_ENV"] = "test"

$LOAD_PATH.push File.expand_path("../../../spec", __FILE__)
$LOAD_PATH.push File.expand_path("../../lib", __FILE__)
$LOAD_PATH.push File.expand_path("../../../game/lib", __FILE__)

require "notifications"
require "game"
require "ruby_event_store/rspec"

module InMemoryEventStore
  def event_store
    @event_store ||=
      RailsEventStore::Client
        .new(repository: RailsEventStore::InMemoryRepository.new)
        .tap do |client|
          client.subscribe(
            ->(event) { Notifications::SlackNotifier.new(logger: Rails.logger, event_store: client).call(event) },
            [Game::NewTurnStarted, Game::PlayerDisconnected]
          )
        end
  end
end
