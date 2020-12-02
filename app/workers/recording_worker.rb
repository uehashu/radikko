# coding: utf-8
# 録音をスケジュールによって開始するためのクラス.
class RecordingWorker
  include Sidekiq::Worker
  require 'program_recorder'

  sidekiq_options retry: false

  def perform(recording_id)
    Rails.logger.info("pulsed")
    recording = Recording.find(recording_id)

    # Configureで保存場所が設定されていて，かつ空白でない場合は，設定された値を使う．
    # 設定されていない，もしくは設定されていても空白な場合は，デフォルトの値を使う．
    storedir = '/var/radikko'
    if Configure.exists?(key: 'storedir') &&
         !Configure.find_by(key: 'storedir').value.blank?
      storedir = Configure.find_by(key: 'storedir').value
    end

    recording.update_attribute(:is_recorded, true)
    filename_full = storedir + "/" + recording.filename
    ProgramRecorder.record(recording.station_id,
                           recording.recording_second,
                           filename_full,
                           album: recording.title,
                           title: recording.start_datetime)
  end
end
