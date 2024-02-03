class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:say]

  def show
    current_turn = Game::CurrentTurn.new(Rails.configuration.event_store).call("Game$#{params[:id]}")
    time_left = begin
      current_turn.ends_at - Time.zone.now
    rescue StandardError
      365.days
    end

    game_name = ReadModel::GameReadModel.find(params[:id]).name.capitalize

    render(
      :show,
      locals: {
        turn: current_turn.turn,
        unfinished_players: Player.where(id: current_turn.unfinished_player_ids),
        time_left: time_left,
        game_name: game_name
      }
    )
  end

  def say
    text = params[:text]
    game_id = params[:game_id]
    gandhi_url = "https://vignette.wikia.nocookie.net/civilization/images/3/36/Gandhi_%28Civ5%29.png/revision/latest?cb=20121104232443"
    game = ReadModel::GameReadModel.find_by(id: game_id)
    client = Slack::Web::Client.new(token: game.slack_token)
    begin
      client.chat_postMessage(channel: game.slack_channel, text: text, as_user: false, icon_url: gandhi_url)
    rescue => e
      puts(e.inspect)
    end

    head(:ok)
  end
end
