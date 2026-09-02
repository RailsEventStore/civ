require "rails_helper"

RSpec.describe "Environment variables" do
  it "are loaded from the .env file matching the current environment" do
    expect(ENV["DOTENV_LOADED"]).to eq("yes")
  end
end
