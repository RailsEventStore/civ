require "rails_helper"

RSpec.describe "game chronicle" do
  def game_id
    "d1465241-0e1a-4408-bc64-3f97e8c5b3b0"
  end

  before do
    Game::Service.new(Rails.configuration.event_store)
      .host_game(Game::HostGame.new(game_id, 24.hours))
  end

  it "shows the chronicle entries newest last, in the order events occurred" do
    Chronicle::GameChronicleEntry.create!(
      game_id: game_id,
      event_type: "city_founded",
      occurred_at: Time.zone.parse("2026-01-01 10:00"),
      text: "Rome was founded."
    )
    Chronicle::GameChronicleEntry.create!(
      game_id: game_id,
      event_type: "city_conquered",
      occurred_at: Time.zone.parse("2026-01-02 10:00"),
      text: "Rome fell to Carthage."
    )

    get "/games/#{game_id}/chronicle"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Rome was founded.")
    expect(response.body.index("Rome was founded."))
      .to be < response.body.index("Rome fell to Carthage.")
  end

  it "does not show entries from other games" do
    Chronicle::GameChronicleEntry.create!(
      game_id: SecureRandom.uuid,
      event_type: "city_founded",
      occurred_at: Time.zone.now,
      text: "A city in another game."
    )

    get "/games/#{game_id}/chronicle"

    expect(response.body).not_to include("A city in another game.")
  end
end
