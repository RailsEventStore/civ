require "rails_helper"

module Chronicle
  RSpec.describe TurnYearMapper do
    subject(:mapper) { TurnYearMapper.new }

    specify "turn 0 maps to 4000 BC" do
      expect(mapper.year_for(0)).to eq("4000 BC")
    end

    specify "turn 5 maps to 3700 BC" do
      expect(mapper.year_for(5)).to eq("3700 BC")
    end

    specify "turn 500 maps to 2220 AD" do
      expect(mapper.year_for(500)).to eq("2220 AD")
    end

    specify "unknown turn returns Unknown year" do
      expect(mapper.year_for(9999)).to eq("Unknown year")
    end
  end
end
