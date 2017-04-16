class PitbossEntriesController < ApplicationController
  before_action :set_pitboss_entry, only: [:show, :edit, :update, :destroy]

  # GET /pitboss_entries
  # GET /pitboss_entries.json
  def index
    @pitboss_entries = PitbossEntry.order("timestamp ASC").paginate(:page => params[:page], :per_page => 30)
  end

  # POST /pitboss_entries
  # POST /pitboss_entries.json
  def create
    @pitboss_entry = PitbossEntry.new(pitboss_entry_params)
    @pitboss_entry.save!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pitboss_entry
      @pitboss_entry = PitbossEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pitboss_entry_params
      params.require(:pitboss_entry).permit(:game_name, :entry_type, :value, :timestamp)
    end
end
