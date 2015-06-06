# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


require "csv"
require "station_poller"
require "program_poller"

CSV.foreach("db/area.csv") do |row|
  unless Area.exists?(area_id: row[0])
    Area.create(area_id: row[0], area_name: row[1], area_name_kana: row[2])
  end
end


stations = StationPoller.get_stations_in_allarea
stations.each do |station|
  unless Station.exists?(area_id: station.area_id, station_id: station.station_id)
    Station.create(station_id: station.station_id,
                   station_name: station.station_name,
                   station_name_ascii: station.station_name_ascii,
                   area_id: station.area_id)
  end
end


station_uniq_ids = Array.new()
stations.each do |station|
  unless station_uniq_ids.include?(station.station_id)
    station_uniq_ids << station.station_id
  end
end

station_uniq_ids.each do |station_id|
  weeklyprograms = ProgramPoller.get_weeklyprograms_from_stationid(station_id)
  weeklyprograms.each do |program|
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
  p "#{station_id} is finished."
end
