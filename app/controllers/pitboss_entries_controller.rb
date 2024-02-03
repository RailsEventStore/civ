class PitbossEntriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  http_basic_authenticate_with name: "", password: Rails.application.secrets.pitboss_entries_password

  def index
    @pitboss_entries = PitbossEntry.order("id ASC").paginate(page: params[:page], per_page: 30)
  end

  def create
    @pitboss_entry = PitbossEntry.new(pitboss_entry_params)
    @pitboss_entry.save!
  end

  private

  def pitboss_entry_params
    params.require(:pitboss_entry).permit(:game_name, :entry_type, :value, :timestamp)
  end
end
