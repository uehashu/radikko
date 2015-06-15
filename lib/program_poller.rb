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
  attr_reader :weeklyprogramlist_url_prefix,
              :todayprogramlist_url_prefix,
              :tomorrowprogramlist_url_prefix
  @weeklyprogramlist_url_prefix = "http://radiko.jp/v2/api/program/station/weekly?station_id="
  @todayprogramlist_url_prefix = "http://radiko.jp/v2/api/program/today?area_id="
  @tomorrowprogramlist_url_prefix = "http://radiko.jp/v2/api/program/tomorrow?area_id="
  
  # station_id から週間番組表の配列を取得するメソッド.
  def self.get_weeklyprograms_from_stationid(station_id)
    return get_programs_from_url("#{@weeklyprogramlist_url_prefix}#{station_id}")
  end
  
  
  
  # area_id から今日の番組表の配列を取得するメソッド.
  def self.get_todayprograms_from_areaid(area_id)
    return get_programs_from_url("#{@todayprogramlist_url_prefix}#{area_id}")
  end
  
  
  
  # area_id から明日の番組表の配列を取得するメソッド.
  def self.get_tomorrowprograms_from_areaid(area_id)
    return get_programs_from_url("#{@tomorrowprogramlist_url_prefix}#{area_id}")
  end
  
  
  
  # 全ての放送局における週間番組表の配列を取得するメソッド.
  def self.get_all_weeklyprograms
    programs = Array.new()
    station_uniq_ids = Array.new()
    Station.all.each do |station|
      unless station_uniq_ids.include?(station.station_id.to_s)
        station_uniq_ids << station.station_id.to_s
      end
    end
        
    station_uniq_ids.each do |station_id|
      programs.concat(get_weeklyprograms_from_stationid(station_id))
    end
    return programs
  end
  
  
  
  # 全ての地域における今日の番組表の配列を取得するメソッド.
  def self.get_all_todayprograms
    programs = Array.new()
    Area.all.each do |area|
      programs.concat(get_todayprograms_from_areaid(area.area_id))
    end
    return programs
  end
  
  
  
  # 全ての地域における明日の番組表の配列を取得するメソッド.
  def self.get_all_tomorrowprograms
    programs = Array.new()
    Area.all.each do |area|
      programs.concat(get_tomorrowprograms_from_areaid(area.area_id))
    end
    return programs
  end
  
  
  
  # station_id から週間番組表を取得し, それを用いてレコードを更新するメソッド.
  def self.update_weeklyprograms_from_stationid(station_id)
    weeklyprograms = get_weeklyprograms_from_stationid(station_id)
    update_programs_from_tempprograms(weeklyprograms)
  end
  
  
  
  # area_id から今日の番組表を取得し, それを用いてレコードを更新するメソッド.
  def self.update_todayprograms_from_areaid(area_id)
    todayprograms = get_todayprograms_from_areaid(area_id)
    update_programs_from_tempprograms(todayprograms)
  end
  
  
  
  # area_id から明日の番組表を取得し, それを用いてレコードを更新するメソッド.
  def self.update_tomorrowprograms_from_areaid(area_id)
    tomorrowprograms = get_tomorrowprograms_from_areaid(area_id)
    update_programs_from_tempprograms(tomorrowprograms)
  end
  
  
  
  # 全ての放送局における週間番組表を取得し, それを用いてレコードを更新するメソッド.
  def self.update_all_weeklyprograms
    station_uniq_ids = Array.new()
    Station.all.each do |station|
      unless station_uniq_ids.include?(station.station_id.to_s)
        station_uniq_ids << station.station_id.to_s
      end
    end

    station_uniq_ids.each do |station_id|
      update_weeklyprograms_from_stationid(station_id)
    end
  end
  
  
  
  # 全ての地域における今日の番組表を取得し, それを用いてレコードを更新するメソッド.
  def self.update_all_todayprograms
    Area.all.each do |area|
      update_todayprograms_from_areaid(area.area_id)
    end
  end
  
  
  
  # 全ての地域における明日の番組表を取得し, それを用いてレコードを更新するメソッド.
  def self.update_all_tomorrowprograms
    Area.all.each do |area|
      update_tomorrowprograms_from_areaid(area.area_id)
    end
  end
  
  
  
  private
  
  # url から番組表を取得するメソッド. 
  def self.get_programs_from_url(url)
    parsed_url = URI.parse(url)
    programs_xml = Net::HTTP.get(parsed_url)
    
    programs = Array.new()
    
    # xml をパースして, 各番組情報を抽出
    begin
      doc = REXML::Document.new(programs_xml)
      
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
    rescue REXML::ParseException
      p "#{url} parse exception."
    end
    
    return programs
  end
  
  
  
  # temp_programs を用いて番組表を更新するメソッド.
  def self.update_programs_from_tempprograms(temp_programs)
    temp_programs.each do |program|
      unless Program.exists?(station_id: program.station_id, start_date: program.start_date,
                             end_date: program.end_date, duration_sec: program.duration_sec,
                             title: program.title)
        Program.create(station_id: program.station_id, start_date: program.start_date,
                       end_date: program.end_date, duration_sec: program.duration_sec,
                       title: program.title, subtitle: program.subtitle,
                       performers: program.performers, description: program.description,
                       reserved: "no")
      end
    end
  end
end
