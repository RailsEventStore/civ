class PlayerStatsController < ApplicationController
  EnrichedPlayer = Struct.new(:id, :slack_name, :steam_name, :slothfulness)

  def index
    game_id = params[:game_id] || "all"

    relevant_players, @title = if game_id == "all"
      [Player.all, "All games"]
    else
      players = Game::Players.new(Rails.configuration.event_store).call("Game$#{game_id}")
      [Player.where(id: players.player_ids), ReadModel::GameReadModel.find(game_id).name.capitalize]
    end

    @players = relevant_players
      .map do |player|
        stat = ReadModel::PlayerStat.find_by(player_id: player.id, game_id: game_id)
        EnrichedPlayer.new(player.id, player.slack_name, player.steam_name, stat&.slothfulness.to_d)
      end
      .sort_by(&:slothfulness)
      .reverse
  end
end
