class RootController < ApplicationController
  def welcome
    render :welcome, locals: {
      games: ReadModel::Game.all
    }
  end
end
