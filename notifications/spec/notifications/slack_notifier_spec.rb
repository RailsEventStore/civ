require_relative "../spec_helper"

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

    def player_2
      "95692a5a-04c4-4467-b1dc-76b095a76c4b"
    end

    def player_3
      "91488a8d-0e55-43e8-a95a-84ea0122cd0f"
    end

    def game_read_model
      ReadModel::GameReadModel.find_or_create_by!(
        id: game_id,
        slack_token: game_slack_token,
        slack_channel: game_slack_channel,
        ip_address: game_ip_address
      )
    end

    def given(*domain_events)
      domain_events.each { |domain_event| event_store.publish(domain_event, stream_name: "Game$#{game_id}") }
    end

    specify("new turn notification") do
      game_read_model
      event = Game::NewTurnStarted.new(data: {turn: 1, game_id: game_id})
      stub = stub_request(:post, "https://slack.com/api/chat.postMessage")
        .with(
          body: {
            "channel" => "#arkency58",
            "text" => "Game  Turn 1 <!channel>\nsteam://run/8930/q/%2Bconnect%2010.4.0.28"
          },
          headers: {
            "Authorization" => "Bearer xoxb-302139800755-nR1O848GLyVS5ZfNNMpBLm0b",
            "Accept" => "application/json; charset=utf-8",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        )
        .to_return(status: 200, body: {ok: true}.to_json, headers: {})
      event_store.publish(event, stream_name: game_id)
      expect(stub).to have_been_requested
    end

    specify("ping last remaining player") do
      player_1 = Player.create!(steam_name: "some_player", slack_name: "slack_user")
      game_read_model

      stub = stub_request(:post, "https://slack.com/api/chat.postMessage")
        .with(
          body: {
            "channel" => "#arkency58",
            "text" => "Turn <@slack_user>"
          },
          headers: {
            "Authorization" => "Bearer xoxb-302139800755-nR1O848GLyVS5ZfNNMpBLm0b",
            "Accept" => "application/json; charset=utf-8",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        )
        .to_return(status: 200, body: {ok: true}.to_json, headers: {})

      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours.to_i, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1.id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3}),
        Game::NewTurnStarted.new(data: {turn: 1}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerDisconnected.new(data: {slot: 2, game_id: game_id})
      )
      expect(stub).to have_been_requested
    end

    specify("ping multiple remaining players") do
      player_1 = Player.create!(steam_name: "some_player", slack_name: "slack_user")
      player_2 = Player.create!(
        steam_name: "anohter_player",
        slack_name: "anohter_player",
        slack_identifier: "some_hidden_identifier"
      )
      ReadModel::GameReadModel.find_or_create_by!(
        id: game_id,
        slack_token: game_slack_token,
        slack_channel: game_slack_channel,
        ip_address: game_ip_address,
        number_of_remaining_players_to_notify: 2
      )

      stub0 = stub_request(:post, "https://slack.com/api/chat.postMessage")
        .with(
          body: {
            "channel" => "#arkency58",
            "text" => "Turn <@slack_user> <@some_hidden_identifier>"
          },
          headers: {
            "Authorization" => "Bearer xoxb-302139800755-nR1O848GLyVS5ZfNNMpBLm0b",
            "Accept" => "application/json; charset=utf-8",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        )
        .to_return(status: 200, body: {ok: true}.to_json, headers: {})

      stub1 = stub_request(:post, "https://slack.com/api/chat.postMessage")
        .with(
          body: {
            "channel" => "#arkency58",
            "text" => "Turn <@slack_user>"
          },
          headers: {
            "Authorization" => "Bearer xoxb-302139800755-nR1O848GLyVS5ZfNNMpBLm0b",
            "Accept" => "application/json; charset=utf-8",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Content-Type" => "application/x-www-form-urlencoded"
          }
        )
        .to_return(status: 200, body: {ok: true}.to_json, headers: {})

      given(
        Game::GameHosted.new(data: {turn_timer: 24.hours.to_i, game_id: game_id}),
        Game::PlayerRegistered.new(data: {slot_id: 1, player_id: player_1.id}),
        Game::PlayerRegistered.new(data: {slot_id: 2, player_id: player_2}),
        Game::PlayerRegistered.new(data: {slot_id: 3, player_id: player_3}),
        Game::NewTurnStarted.new(data: {turn: 1}),
        Game::PlayerEndedTurn.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerDisconnected.new(data: {slot: 3, game_id: game_id}),
        Game::PlayerEndedTurn.new(data: {slot: 2, game_id: game_id}),
        Game::PlayerDisconnected.new(data: {slot: 2, game_id: game_id})
      )
      expect(stub0).to have_been_requested
      expect(stub1).to have_been_requested
    end
  end
end
