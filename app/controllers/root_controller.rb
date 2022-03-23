class RootController < ApplicationController
  def welcome
    render :welcome, locals: { games: ReadModel::GameReadModel.all }
  end
end
