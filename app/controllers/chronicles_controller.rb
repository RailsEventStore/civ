class ChroniclesController < ApplicationController
  def show
    game = ReadModel::GameReadModel.find(params[:game_id])

    render(
      :show,
      locals: {
        game_name: game.name.capitalize,
        entries: Chronicle::GameChronicleEntry
          .where(game_id: game.id)
          .order(:occurred_at)
      }
    )
  end
end
