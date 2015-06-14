# coding: utf-8
require "net/http"
require "rexml/document"


class TempProgram
  attr_reader :station_id,:start_date,:end_date,:duration_sec,
              :title,:subtitle,:performers,:description
  
  def initialize(station_id, start_date, end_date, duration_sec,
                 title, subtitle, performers, description)
    @station_id = station_id
    @start_date = Time.zone.parse(start_date)
    @end_date = Time.zone.parse(end_date)
    @duration_sec = duration_sec.to_i
    @title = title
    @subtitle = subtitle
    @performers = performers
    @description = description
  end
end



class ProgramPoller
  attr_reader :programlist_url_prefix
  @programlist_url_prefix = "http://radiko.jp/v2/api/program/station/weekly?station_id="
  
  # url から番組表の配列を取得するメソッド.
  def self.get_weeklyprograms_from_stationid(station_id)
    parsed_url = URI.parse("#{@programlist_url_prefix}#{station_id}")
    weeklyprograms_xml = Net::HTTP.get(parsed_url)
    
    programs = Array.new()
    
    # xml をパースして, 各番組情報を抽出
    doc = REXML::Document.new(weeklyprograms_xml)
    doc.elements.each('radiko/stations') do |program_per_station|
      program_per_station.elements.each('station') do |station|
        station_id = station.attribute('id').to_s
        station.elements.each('scd/progs') do |program_daily|
          program_daily.elements.each('prog') do |program|
            start_date = program.attribute('ft').to_s
            end_date = program.attribute('to').to_s
            duration_sec = program.attribute('dur').to_s
            title = program.elements['title'].text
            subtitle = program.elements['sub_title'].text
            performers = program.elements['pfm'].text
            description = program.elements['desc'].text
            programs << TempProgram.new(station_id,start_date,end_date,duration_sec,
                                        title,subtitle,performers,description)
          end
        end
      end
    end
    
    return programs
  end
end
