class PlayerStatsController < ApplicationController
  EnrichedPlayer = Struct.new(:id, :slack_name, :steam_name, :slothfulness)

  def index
    game_id = params[:game_id] || "all"
    @players = Player
      .all
      .map do |player|
        stat = ReadModel::PlayerStat.find_by(player_id: player.id, game_id: game_id)
        EnrichedPlayer.new(player.id, player.slack_name, player.steam_name, stat&.slothfulness.to_d)
      end
      .sort_by(&:slothfulness)
      .reverse
  end
end
