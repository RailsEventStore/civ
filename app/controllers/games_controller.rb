class GamesController < ApplicationController
  def show
    current_turn = Game::CurrentTurn.new(Rails.configuration.event_store).call("Game$#{params[:id]}")
    time_left =
      begin
        current_turn.ends_at - Time.zone.now
      rescue StandardError
        365.days
      end
    game_name = ReadModel::GameReadModel.find(params[:id]).name.capitalize

    render :show,
           locals: {
             turn: current_turn.turn,
             unfinished_players: Player.where(id: current_turn.unfinished_player_ids),
             time_left: time_left,
             game_name: game_name
           }
  end
end
