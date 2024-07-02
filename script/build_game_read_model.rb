stream_name = "Game$#{ARGV[0]}"
event_store = Rails.configuration.event_store

handler = ReadModel::GameReadModelUpdater.new(logger: Rails.logger)
event_store.read.stream(stream_name) do |event|
  handler.call(event)
end
