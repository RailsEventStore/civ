stream_name = "Game$d3f4facd-3b6f-4cae-83d2-dbcaee74a5b5"
event_store = Rails.configuration.event_store

handler = ReadModel::GameReadModelUpdater.new(logger: Rails.logger)
event_store.read.stream(stream_name).to_a.each do |event|
  handler.call(event)
end
