ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.push File.expand_path('../../../spec', __FILE__)
$LOAD_PATH.push File.expand_path('../../lib',  __FILE__)

require 'game'
require 'rails_event_store/rspec'

module InMemoryEventStore
  def event_store
    @event_store ||= RailsEventStore::Client.new(repository: RailsEventStore::InMemoryRepository.new)
  end
end