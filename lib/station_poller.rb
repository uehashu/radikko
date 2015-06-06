# coding: utf-8
require "net/http"
require "rexml/document"

class TempStation
  attr_reader :station_id, :station_name, :station_name_ascii, :area_id
  
  def initialize(station_id, station_name, station_name_ascii, area_id)
    @station_id = station_id
    @station_name = station_name
    @station_name_ascii = station_name_ascii
    @area_id = area_id
  end
end



class StationPoller
  attr_reader :stationlist_url_prefix
  @stationlist_url_prefix = "http://radiko.jp/v2/station/list"
  
  # エリアごとの放送局リストを取得する. 
  def self.get_stations_in_area(area_id)
    parsed_url = URI.parse("#{@stationlist_url_prefix}/#{area_id}.xml")
    stationlist_xml = Net::HTTP.get(parsed_url)

    stations = Array.new()
    doc = REXML::Document.new(stationlist_xml)
    doc.elements.each("stations/station") do |e|
      station_id = e.elements["id"].text
      station_name = e.elements["name"].text
      station_name_ascii = e.elements["ascii_name"].text

      stations << TempStation.new(station_id, station_name, station_name_ascii, area_id)
    end

    return stations
  end
  

  
  # 全国の放送局リストを取得する. 
  def self.get_stations_in_allarea
    stations = Array.new()
    Area.all.each do |area|
      stations.concat(StationPoller.get_stations_in_area(area.area_id))
    end
    return stations
  end
end
