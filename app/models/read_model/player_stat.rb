module ReadModel
  class PlayerStat < ApplicationRecord
    self.table_name = "player_stats"

    def slothfulness
      if turns_taken.to_i != 0
        (turns_last.to_i / turns_taken.to_d)
      else
        0
      end
    end
  end
end
