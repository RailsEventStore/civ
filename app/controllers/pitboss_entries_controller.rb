class PitbossEntriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_with_password, only: [:create]

  def index
    @pitboss_entries = PitbossEntry.order("id ASC").paginate(page: params[:page], per_page: 30)
  end

  def create
    @pitboss_entry = PitbossEntry.new(pitboss_entry_params)
    @pitboss_entry.save!
  end

  private

  def authenticate_with_password
    expected_password = Rails.application.credentials.pitboss_entries_password

    return head :unauthorized unless expected_password

    authenticate_or_request_with_http_basic do |username, password|
      password == expected_password
    end
  end

  def pitboss_entry_params
    params.require(:pitboss_entry).permit(:game_name, :entry_type, :value, :timestamp)
  end
end
