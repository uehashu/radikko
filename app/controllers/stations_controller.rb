class StationsController < ApplicationController
  before_action :set_item, only: [:show]
  
  def index
    @stations = Station.all
  end

  def show
  end
  
  
  
  private

  def set_item
    @station_id = Station.find(params[:id]).station_id
    @area_id = Station.find(params[:id]).area_id
    @station_name = Station.find(params[:id]).station_name
    @programs = Program.where(station_id: @station_id)
  end
end
