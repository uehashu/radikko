class AreasController < ApplicationController
  before_action :set_item, only: [:show]
  
  def index
    @areas = Area.all
  end
  
  def show
    monday = Date.today.in_time_zone.beginning_of_week
    @programs = Hash.new
    @stations.each do |station|
      station_id = station.station_id
      @programs[station_id] =
        Program.where(station_id: station_id).where("start_date >= ?", monday).order("start_date")
    end
  end
  
  
  
  private
  
  def set_item
    @area_id = Area.find(params[:id]).area_id
    @area_name_kana = Area.find(params[:id]).area_name_kana
    @stations = Station.where(area_id: params[:id])
  end
end
