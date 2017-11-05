class HomeController < ApplicationController
  def index
    current_turn = Game::CurrentTurn.new(Rails.configuration.event_store).call
    time_left    = current_turn.ends_at - Time.zone.now

    render :index,
      locals: {
        turn: current_turn.turn,
        unfinished_players: Player.where(current_turn.unfinished_player_ids),
        time_left: time_left
      }
  end
end
