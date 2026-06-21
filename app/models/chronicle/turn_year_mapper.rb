require "csv"

module Chronicle
  class TurnYearMapper
    TURN_TO_YEAR = CSV.read(
      Rails.root.join("config", "civ5_turn_years.csv"),
      headers: true
    ).each_with_object({}) do |row, map|
      map[row["Quick Gameplay Turn"].to_i] = row["Year"]
    end.freeze

    def year_for(turn)
      TURN_TO_YEAR.fetch(turn, "Unknown year")
    end
  end
end
