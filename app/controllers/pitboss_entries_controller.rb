class PitbossEntriesController < ApplicationController
  before_action :set_pitboss_entry, only: [:show, :edit, :update, :destroy]

  # GET /pitboss_entries
  # GET /pitboss_entries.json
  def index
    @pitboss_entries = PitbossEntry.paginate(:page => params[:page], :per_page => 30)
  end

  # GET /pitboss_entries/1
  # GET /pitboss_entries/1.json
  def show
  end

  # GET /pitboss_entries/new
  def new
    @pitboss_entry = PitbossEntry.new
  end

  # GET /pitboss_entries/1/edit
  def edit
  end

  # POST /pitboss_entries
  # POST /pitboss_entries.json
  def create
    @pitboss_entry = PitbossEntry.new(pitboss_entry_params)

    respond_to do |format|
      if @pitboss_entry.save
        format.html { redirect_to @pitboss_entry, notice: 'Pitboss entry was successfully created.' }
        format.json { render :show, status: :created, location: @pitboss_entry }
      else
        format.html { render :new }
        format.json { render json: @pitboss_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pitboss_entries/1
  # PATCH/PUT /pitboss_entries/1.json
  def update
    respond_to do |format|
      if @pitboss_entry.update(pitboss_entry_params)
        format.html { redirect_to @pitboss_entry, notice: 'Pitboss entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @pitboss_entry }
      else
        format.html { render :edit }
        format.json { render json: @pitboss_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pitboss_entries/1
  # DELETE /pitboss_entries/1.json
  def destroy
    @pitboss_entry.destroy
    respond_to do |format|
      format.html { redirect_to pitboss_entries_url, notice: 'Pitboss entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pitboss_entry
      @pitboss_entry = PitbossEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pitboss_entry_params
      params.require(:pitboss_entry).permit(:game_name, :entry_type, :player_name, :timestamp)
    end
end
