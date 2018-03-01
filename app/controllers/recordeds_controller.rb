class RecordedsController < ApplicationController
  before_action :set_recording, only: [:show, :destroy, :download]

  # GET /recorded
  def index
    @recordings = Recording.where(is_recorded: true).order(:start_datetime).reverse_order
  end

  def show
  end

  # DELETE /recorded/1
  def destroy
    @recording.destroy
    file_path = Configure.where(key: "storedir").first.value + "/" + @recording.filename
    if File.exist?(file_path)
      File.delete(file_path)
    end
    redirect_to recordeds_url, notice: 'Recorded was successfully destroyed.'
  end

  def download
    file_name = ERB::Util.url_encode(@recording.filename)
    file_path = Configure.where(key: "storedir").first.value + "/" + @recording.filename
    send_file(file_path, filename: file_name)
  end

  private
  def set_recording
    @recording = Recording.find(params[:id])
  end

end
