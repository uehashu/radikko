class RecordingsController < ApplicationController
  before_action :set_recording, only: [:show, :edit, :update, :destroy]

  # GET /recordings
  # GET /recordings.json
  def index
    @recordings = Recording.where(is_recorded: false)
  end

  # GET /recordings/1
  # GET /recordings/1.json
  def show
  end

  # GET /recordings/new
  def new
    if params[:program_id] == nil || !Program.exists?(params[:program_id])
      @recording = Recording.new
    else
      program_params = Hash.new
      program = Program.find(params[:program_id])
      program_params[:station_id] = program.station_id
      program_params[:start_datetime] = program.start_date
      program_params[:recording_second] = program.duration_sec
      program_params[:title] = program.title
      program_params[:filename] = program.start_date.strftime('%Y%m%d%H%M') + "_" +
                                  program.title.gsub(/:|;|>|<|"|\/|\?|\\|\*|\|/,"_") +
                                  ".flv"
      @recording = Recording.new(program_params)
    end
  end

  # GET /recordings/1/edit
  def edit
  end

  # POST /recordings
  # POST /recordings.json
  def create
    @recording = Recording.new(recording_params)
    @recording.update_attribute(:is_recorded, false)

    respond_to do |format|
      if @recording.save
        format.html { redirect_to @recording, notice: 'Recording was successfully created.' }
        format.json { render :show, status: :created, location: @recording }
        job_id = RecordingWorker.perform_at(@recording.start_datetime, @recording.id)
        @recording.update_attribute(:job_id, job_id)
      else
        format.html { render :new }
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recordings/1
  # PATCH/PUT /recordings/1.json
  def update
    respond_to do |format|
      if @recording.update(recording_params)
        @recording.update_attribute(:is_recorded, false)
        format.html { redirect_to @recording, notice: 'Recording was successfully updated.' }
        format.json { render :show, status: :ok, location: @recording }
        Sidekiq::ScheduledSet.new.select { |retri|
          retri.jid == @recording.job_id
        }.each(&:delete)
        job_id = RecordingWorker.perform_at(@recording.start_datetime, @recording.id)
        @recording.update_attribute(:job_id, job_id)

      else
        format.html { render :edit }
        format.json { render json: @recording.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recordings/1
  # DELETE /recordings/1.json
  def destroy
    job_id = @recording.job_id
    @recording.destroy
    respond_to do |format|
      format.html { redirect_to recordings_url, notice: 'Recording was successfully destroyed.' }
      format.json { head :no_content }
    end
    Sidekiq::ScheduledSet.new.select { |retri|
      retri.jid == @recording.job_id
    }.each(&:delete)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recording
      @recording = Recording.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recording_params
      #params.require(:recording).permit(:area_id, :station_id, :start_datetime, :recording_second, :title, :filename, :is_recorded)
      params.require(:recording).permit(:area_id, :station_id, :start_datetime, :recording_second, :title, :filename, :job_id)
    end
end
