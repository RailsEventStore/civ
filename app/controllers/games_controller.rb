class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:say]
  http_basic_authenticate_with name: "", password: Rails.application.secrets.say_password, except: :show

  def show
    game = ReadModel::GameReadModel.find(params[:id])
    time_left = begin
      game.ends_at - Time.zone.now
    rescue StandardError
      365.days
    end

    render(
      :show,
      locals: {
        turn: game.turn,
        unfinished_players: Player.where(id: game.unfinished_player_ids),
        time_left: time_left,
        game_name: game.name.capitalize,
        game_id: game.id
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
