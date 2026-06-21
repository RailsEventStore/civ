module Chronicle
  class NarrativeBuilder
    def call(event)
      text = build_text(event)
      return unless text

      GameChronicleEntry.create!(
        game_id: event.data[:game_id],
        event_type: event.class.name,
        occurred_at: event.metadata[:timestamp],
        text: text
      )
    end

    private

    def build_text(event)
      case event
      when Game::NewTurnStarted   then "Turn #{event.data[:turn]} has begun."
      when Game::CityFounded      then "#{player_name(event)} has founded a new city."
      when Game::WarStatusChanged then "War status has changed."
      when Game::CityConquered    then city_conquered_text(event)
      end
    end

    def city_conquered_text(event)
      name = player_name(event)
      case event.data[:action]
      when "puppeted"       then "#{name} has puppeted a city."
      when "annexed"        then "#{name} has annexed a city."
      when "razing_started" then "#{name} has started razing a city."
      else "#{name} has conquered a city."
      end
    end

    def player_name(event)
      game = ReadModel::GameReadModel.find_by(id: event.data[:game_id])
      player_id = game&.registered_slots&.[](event.data[:slot])
      Player.find_by(id: player_id)&.slack_name || "Unknown player"
    end
  end
end
