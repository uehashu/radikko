# coding: utf-8
# 録音をスケジュールによって開始するためのクラス.
class RecordingWorker
  include Sidekiq::Worker
  require 'program_recorder'

  sidekiq_options retry: false

  def perform(recording_id)
    Rails.logger.info("pulsed")
    recording = Recording.find(recording_id)

    recording.update_attribute(:is_recorded, true)
    filename_full = Configure.where(key: "storedir").first.value + "/" + recording.filename
    ProgramRecorder.record(recording.station_id,
                           recording.recording_second,
                           filename_full,
                           album: recording.title,
                           title: recording.start_datetime)
  end
end
