class PlayerStatsController < ApplicationController
  EnrichedPlayer = Struct.new(:id, :slack_name, :steam_name, :slothfulness)

  def index
    @players = Player.all.map do |player|
      stat = ReadModel::PlayerStat.find_by(player_id: player.id)
      slothfulness = if stat&.turns_taken.to_i != 0
        (stat&.turns_last.to_i / stat&.turns_taken.to_d).round(2)
      else
        0
      end
      EnrichedPlayer.new(player.id, player.slack_name, player.steam_name, slothfulness)
    end.sort_by(&:slothfulness).reverse
  end
end
