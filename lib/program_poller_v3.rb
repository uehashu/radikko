# coding: utf-8
require "net/http"
require "rexml/document"


class TempProgramV3
  attr_reader :station_id,:start_date,:end_date,:duration_sec,
              :title,:performers,:description,:image_url

  def initialize(station_id, start_date, end_date, duration_sec,
                 title, performers, description,image_url)
    @station_id = station_id
    @start_date = Time.zone.parse(start_date)
    @end_date = Time.zone.parse(end_date)
    @duration_sec = duration_sec.to_i
    @title = title
    @performers = performers
    @description = description
    @image_url = image_url
  end
end



class ProgramPollerV3
  attr_reader :base_url_v3
  @base_url_v3 = "http://radiko.jp/v3/program/station/date"

  # 放送局と日付から番組表を取得するメソッド．
  def self.get_programs(station_id:, date:)
    programs_url = "#{@base_url_v3}/#{date}/#{station_id}.xml"
    parsed_url = URI.parse(programs_url)
    programs_xml = Net::HTTP.get(parsed_url)

    programs = Array.new()

    # xml をパースして，各番組情報を抽出
    begin
      doc = REXML::Document.new(programs_xml)

      doc.elements.each('radiko/stations') do |program_per_station|
        program_per_station.elements.each('station') do |station|
          station_id = station.attribute('id').to_s
          station.elements.each('progs') do |program_daily|
            program_daily.elements.each('prog') do |program|
              start_date = program.attribute('ft').to_s
              end_date = program.attribute('to').to_s
              duration_sec = program.attribute('dur').to_s
              title = program.elements['title'].text
              performers = program.elements['pfm'].text
              description = program.elements['desc'].text
              image_url = program.elements['img'].text

              programs << TempProgramV3.new(station_id,start_date,end_date,duration_sec,
                                            title,performers,description,image_url)
            end
          end
        end
      end
    rescue REXML::ParseException
      p "#{url} parse exception."
    end

    return programs
  end
end
