class ConfiguresController < ApplicationController
  
  def edit
    @storedir = Configure.find_or_create_by(key: "storedir").value
  end
  
  
  
  def update
    if params[:commit] == "change"
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
      @storedir = Configure.find_or_create_by(key: "storedir").value
      render :edit
    elsif params[:commit] == "cancel"
      @storedir = Configure.find_or_create_by(key: "storedir").value
      render :edit
    end
  end
end
