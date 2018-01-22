require_relative '../spec_helper'

module Notifications
  RSpec.describe SlackNotifier do
    include InMemoryEventStore

    def game_id
      "2d3e49d1-ff3f-4326-9e30-73463f349a84"
    end

    def game_slack_token
      "xoxb-302139800755-nR1O848GLyVS5ZfNNMpBLm0b"
    end

    def game_slack_channel
      "#arkency58"
    end

    def game_ip_address
      "10.4.0.28"
    end

    def game_read_model
      ReadModel::GameReadModel.find_or_create_by!(
        id:            game_id,
        slack_token:   game_slack_token,
        slack_channel: game_slack_channel,
        ip_address:    game_ip_address
      )
    end

    before do
      event_store.subscribe(->(event) { Notifications::SlackNotifier.new.call(event) }, [
        Game::NewTurnStarted
      ])
      game_read_model
    end

    specify do
      event = Game::NewTurnStarted.new(data: { turn: 1, game_id: game_id })
      stub = stub_request(:post, "https://slack.com/api/chat.postMessage").
         with(body: {"as_user"=>"false",
              "channel"=>"#arkency58",
              "icon_url"=>"https://vignette.wikia.nocookie.net/civilization/images/3/36/Gandhi_%28Civ5%29.png/revision/latest?cb=20121104232443",
              "text"=>"Game  Turn 1 <!channel>\nsteam://run/8930/q/%2Bconnect%2010.4.0.28",
              "token"=>"xoxb-302139800755-nR1O848GLyVS5ZfNNMpBLm0b"},
          headers: {'Accept'=>'application/json; charset=utf-8',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type'=>'application/x-www-form-urlencoded',
            'User-Agent'=>'Slack Ruby Client/0.11.0'}).
         to_return(status: 200, body: {ok: true}.to_json, headers: {})
      event_store.publish_event(event, stream_name: game_id)
      expect(stub).to have_been_requested
    end
  end
end
