# coding: utf-8
class StationsController < ApplicationController
  before_action :set_item, only: [:show]
  
  def index
    @stations = Station.all
  end

  def show
    
  end
  
  
  
  private

  def set_item
    @today = Date.today.in_time_zone
    monday = @today.beginning_of_week
    @week = Array.new(7);
    for i in 0..6 do
      @week[i] = (monday + i.day)
    end
    
    @station = Station.find_by_station_id(params[:id])
    @station_id = @station.station_id
    @area_id = @station.area_id
    @station_name = @station.station_name
    @programs = Program.where(station_id: @station_id).where("start_date >= ?", @week[0]).order("start_date")
    @firstProgram_ids_ofDay = Array.new(7)
    for i in 0..6 do
      if @programs.find_by("start_date >= ? and start_date < ?", @week[i], (@week[i]+1.day)) != nil
      then
        @firstProgram_ids_ofDay[i] = @programs.find_by("start_date >= ? and start_date < ?", @week[i], (@week[i]+1.day)).id
      else
        @firstProgram_ids_ofDay[i] = nil;
      end
    end
  end
end
