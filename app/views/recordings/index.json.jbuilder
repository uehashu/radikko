json.array!(@recordings) do |recording|
  json.extract! recording, :id, :area_id, :station_id, :start_datetime, :recording_second, :title, :filename, :is_recorded
  json.url recording_url(recording, format: :json)
end
