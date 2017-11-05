class PitbossEntry < ApplicationRecord
  after_create_commit do
    Rails.configuration.event_store.publish_event(Game::NewTurnStarted.new)
  end
end
