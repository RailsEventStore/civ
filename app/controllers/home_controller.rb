class HomeController < ApplicationController
  def index
    @current_turn = Game::CurrentTurn.new(Rails.configuration.event_store).call
  end
end
