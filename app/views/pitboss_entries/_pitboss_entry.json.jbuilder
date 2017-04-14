json.extract! pitboss_entry, :id, :game_name, :entry_type, :player_name, :timestamp, :created_at, :updated_at
json.url pitboss_entry_url(pitboss_entry, format: :json)
