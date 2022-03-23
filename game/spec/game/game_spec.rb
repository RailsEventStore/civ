require_relative "../spec_helper"

module Game
  RSpec.describe Game do
    specify do
      game = Game.new(game_id)
      game.host_game(24.hours)

      expect(game).to have_applied(an_event(GameHosted).with_data(turn_timer: 24.hours, game_id: game_id))
    end

    specify do
      game = Game.new(game_id)
      game.register_player(player_id, slot_id)

      expect(game).to have_applied(
        an_event(PlayerRegistered).with_data(slot_id: slot_id, player_id: player_id, game_id: game_id)
      )

      game.unregister_player(player_id, slot_id)
      expect(game).to have_applied(
        an_event(PlayerUnregistered).with_data(slot_id: slot_id, player_id: player_id, game_id: game_id)
      )
    end

    def game_id
      "722a8528-caf7-4424-81d1-cbe30ec1de68"
    end

    def player_id
      "7f27f9b8-38fd-4c1d-b26d-fd7193ac1be4"
    end

    def slot_id
      0
    end
  end
end
