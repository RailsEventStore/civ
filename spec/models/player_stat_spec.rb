require "rails_helper"

module ReadModel
  RSpec.describe PlayerStat do
    def player_id
      "4e7b58e1-ccb9-4159-b891-48e954d1faae"
    end

    specify "zero turns taken returns 0" do
      stat = PlayerStat.new(player_id: player_id, turns_taken: 0, turns_last: 0)

      expect(stat.slothfulness).to eq(0)
    end

    specify "nil turns taken returns 0" do
      stat = PlayerStat.new(player_id: player_id, turns_taken: nil, turns_last: nil)

      expect(stat.slothfulness).to eq(0)
    end

    specify "no turns last gives 0 slothfulness" do
      stat = PlayerStat.new(player_id: player_id, turns_taken: 10, turns_last: 0)

      expect(stat.slothfulness).to eq(0)
    end

    specify "always last gives slothfulness of 1" do
      stat = PlayerStat.new(player_id: player_id, turns_taken: 5, turns_last: 5)

      expect(stat.slothfulness).to eq(1)
    end

    specify "returns fractional slothfulness" do
      stat = PlayerStat.new(player_id: player_id, turns_taken: 10, turns_last: 3)

      expect(stat.slothfulness).to eq(0.3.to_d)
    end
  end
end
