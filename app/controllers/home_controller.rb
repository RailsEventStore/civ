class HomeController < ApplicationController
  def index
    current_turn = Game::CurrentTurn.new(Rails.configuration.event_store).call
    turn_timer   = 24.hours
    time_left    = current_turn.started_at + turn_timer - Time.zone.now if current_turn.started_at

    render :index,
      locals: {
        turn: current_turn.turn,
        done: current_turn.done,
        time_left: time_left
      }
  end
end
