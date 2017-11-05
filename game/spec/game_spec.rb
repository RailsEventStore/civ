module Game
  RSpec.describe Game do
    specify do
      play = Game.new('722a8528-caf7-4424-81d1-cbe30ec1de68')
      play.register_player('7f27f9b8-38fd-4c1d-b26d-fd7193ac1be4', 0)

      expect(play).to have_applied(
        an_event(PlayerRegistered)
          .with_data(
            slot_id: 0,
            player_id: '7f27f9b8-38fd-4c1d-b26d-fd7193ac1be4',
            game_id: '722a8528-caf7-4424-81d1-cbe30ec1de68'
          )
      )
    end
  end
end
