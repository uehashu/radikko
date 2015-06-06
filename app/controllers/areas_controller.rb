class AreasController < ApplicationController
  before_action :set_item, only: [:show]
  
  def index
    @areas = Area.all
  end

  def show
  end
  
  
  
  private
  
  def set_item
    @area_id = Area.find(params[:id]).area_id
    @area_name_kana = Area.find(params[:id]).area_name_kana
    @stations = Station.where(area_id: params[:id])
  end
end
