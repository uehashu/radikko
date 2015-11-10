# coding: utf-8
# 録音をスケジュールによって開始するためのクラス.
class RecordingWorker
  include Sidekiq::Worker

  sidekiq_options retry: false
  
  def perform(program_id)
    
  end
end
