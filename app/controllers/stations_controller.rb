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
    @today = Date.today
    @week = Array.new(7);
    for i in 0..6 do
      @week[i] = (@today - @today.cwday + i + 1)
    end
    
    @station = Station.find(params[:id])
    @station_id = @station.station_id
    @area_id = @station.area_id
    @station_name = @station.station_name
    @programs = Program.where(station_id: @station_id).where("start_date >= ?", @week[0].to_s)
    @firstProgram_ids_ofDay = Array.new(7)
    for i in 0..6 do
      @firstProgram_ids_ofDay[i] = @programs.find_by("start_date >= ? and start_date < ?", @week[i].to_s, (@week[i]+1).to_s).id
    end
  end
end
