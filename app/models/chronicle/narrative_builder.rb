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
      when Game::CityFounded      then "A new city has been founded."
      when Game::WarStatusChanged then "War status has changed."
      when Game::CityConquered    then city_conquered_text(event)
      end
    end

    def city_conquered_text(event)
      case event.data[:action]
      when "puppeted"       then "A city has been puppeted."
      when "annexed"        then "A city has been annexed."
      when "razing_started" then "A city is being razed."
      else "A city has been conquered."
      end
    end
  end
end
