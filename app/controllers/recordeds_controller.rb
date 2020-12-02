class RecordedsController < ApplicationController
  before_action :set_recording, only: [:show, :destroy, :download]

  # GET /recorded
  def index
    @recordings = Recording.where(is_recorded: true).order(:start_datetime).reverse_order.page(params[:page]).per(20)
  end

  def show
  end

  # DELETE /recorded/1
  def destroy
    @recording.destroy
    storedir = "/var/radikko"
    if Configure.exists?(key: 'storedir') &&
         !Configure.find_by(key: 'storedir').value.blank?
      storedir = Configure.find_by(key: 'storedir').value
    end
    
    file_path = storedir + "/" + @recording.filename
    if File.exist?(file_path)
      File.delete(file_path)
    end
    redirect_to recordeds_url, notice: 'Recorded was successfully destroyed.'
  end

  def download
    storedir = "/var/radikko"
    if Configure.exists?(key: 'storedir') &&
         !Configure.find_by(key: 'storedir').value.blank?
      storedir = Configure.find_by(key: 'storedir').value
    end

    file_path = storedir + "/" + @recording.filename
    send_file(file_path, filename: @recording.filename)
  end

  private
  def set_recording
    @recording = Recording.find(params[:id])
  end

end
