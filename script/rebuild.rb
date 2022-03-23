game_id = "2d3e49d1-ff3f-4326-9e30-73463f349a84"
service = Game::Service.new(Rails.configuration.event_store)

RailsEventStoreActiveRecord::Event.delete_all
RailsEventStoreActiveRecord::EventInStream.delete_all
ReadModel::GameReadModel.find(game_id).delete

service.host_game(Game::HostGame.new(game_id, 24.hours))
ReadModel::GameReadModel.where(id: game_id).update_all(name: "arkency3")

%w[
  fa09c04c-6978-470d-b195-442ff9ece774
  3cc439ba-4293-4ad4-8c4c-eb71b497ad73
  cef3a246-8abb-493a-a31b-6fc6db2f052a
  d472969a-9a7a-41c2-9203-b5bc60fc8185
  b1850ec4-326c-4929-a464-b609a9a947b8
  827b63e1-1e54-4b39-a3a6-b71d2a5b642f
].each_with_index do |player_id, slot_id|
  service.register_player(Game::RegisterPlayer.new(game_id, player_id, slot_id))
end

PitbossEntry.order("timestamp ASC").each(&:entry_to_domain_event)
