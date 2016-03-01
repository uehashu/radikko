class ConfiguresController < ApplicationController
  
  def edit
    @path_rtmpdump = Configure.find_or_create_by(key: "path_rtmpdump").value
    @path_swfextract = Configure.find_or_create_by(key: "path_swfextract").value
    @path_ffmpeg = Configure.find_or_create_by(key: "path_ffmpeg").value
    @path_mp4box = Configure.find_or_create_by(key: "path_mp4box").value
    @storedir = Configure.find_or_create_by(key: "storedir").value
  end
  
  
  
  def update
    if params[:commit] == "change"

      # update path_rtmpdump
      path_rtmpdump_record = Configure.find_or_create_by(key: "path_rtmpdump")
      path_rtmpdump_record.update_attributes(value: params[:path_rtmpdump])

      # update path_swfextract
      path_swfextract_record = Configure.find_or_create_by(key: "path_swfextract")
      path_swfextract_record.update_attributes(value: params[:path_swfextract])

      # update path_ffmpeg
      path_ffmpeg_record = Configure.find_or_create_by(key: "path_ffmpeg")
      path_ffmpeg_record.update_attributes(value: params[:path_ffmpeg])
      
      # update path_mp4box
      path_mp4box_record = Configure.find_or_create_by(key: "path_mp4box")
      path_mp4box_record.update_attributes(value: params[:path_mp4box])
      
      # update storedir
      storedir_record = Configure.find_or_create_by(key: "storedir")
      if params[:storedir].empty?
        @error = "Empty storedir is not allowed."
      else
        if storedir_record.update_attributes(value: params[:storedir])
          @success = "Configure updated."
        else
          @error = "Failed to update configure."
        end
      end
      
      # re-render
      @path_rtmpdump = Configure.find_or_create_by(key: "path_rtmpdump").value
      @path_swfextract = Configure.find_or_create_by(key: "path_swfextract").value
      @path_ffmpeg = Configure.find_or_create_by(key: "path_ffmpeg").value
      @path_mp4box = Configure.find_or_create_by(key: "path_mp4box").value
      @storedir = Configure.find_or_create_by(key: "storedir").value
      render :edit

    elsif params[:commit] == "cancel"
      @storedir = Configure.find_or_create_by(key: "storedir").value
      render :edit
    end
  end
end
