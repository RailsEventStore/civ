class GamesController < ApplicationController
  def show
    current_turn = Game::CurrentTurn.new(Rails.configuration.event_store).call
    time_left    = current_turn.ends_at - Time.zone.now

    render :show,
      locals: {
        turn: current_turn.turn,
        unfinished_players: Player.where(id: current_turn.unfinished_player_ids),
        time_left: time_left
      }
  end
end
