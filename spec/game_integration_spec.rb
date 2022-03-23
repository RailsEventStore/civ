require "rails_helper"

RSpec.describe "game integration" do
  def game_id
    "d1465241-0e1a-4408-bc64-3f97e8c5b3b0"
  end

  specify do
    service = Game::Service.new(Rails.configuration.event_store)
    service.host_game(Game::HostGame.new(game_id, 24.hours))

    expect { ReadModel::GameReadModel.find(game_id) }.not_to raise_error
  end
end
