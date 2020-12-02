# coding: utf-8
require 'net/http'
require 'net/https'
require 'uri'
require 'open-uri'
require 'base64'
require 'tmpdir'
require 'securerandom'
require 'taglib'

class ProgramRecorder

  #
  # station_id : string
  # start_date : date
  # recording_second : integer
  # mail_address : string(optional)
  # password : string(optional)
  def self.record(station_id, recording_second, filename,
                  album: nil, artist: nil, genre: nil, title: nil,
                  mail_address: nil, password: nil)
    playerurl = "http://radiko.jp/apps/js/flash/myplayer-release.swf"
    auth_key = "bcd151073c03b352e1ef2fd66c32209da9ca0afa"



    ### step0. 保存用ディレクトリの存在の確認 ###
    storedir = '/var/radikko'
    if Configure.exists?(key: 'storedir') &&
         !Configure.find_by(key: 'storedir').value.blank?
      storedir = Configure.find_by(key: 'storedir').value
    end
    path_storedir = Pathname.new(storedir)
    unless File.exist?(path_storedir.to_s)
    then
      p "ディレクトリがない"
      if Dir.mkdir(path_storedir.to_s, 0755) != 0
      then
        p "ディレクトリつくれない"
        return 1
      end
    end



    ### step1. auth1 して paritalkey を抽出する ###
    url = "https://radiko.jp/v2/api/auth1"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    headers = Hash.new()
    headers["User-Agent"] = "curl/7.56.1"
    headers["Accept"] = "*/*"
    headers["X-Radiko-App"] = "pc_html5"
    headers["X-Radiko-App-Version"] = "0.0.1"
    headers["X-Radiko-User"] = "dummy_user"
    headers["X-Radiko-Device"] = "pc"

    response = http.get(uri.path, headers)

    unless response.class == Net::HTTPOK || response.class == Net::HTTPFound
      p "auth1_fms につながらない"
      p response.code
      return response
    end

    auth_token = response["X-Radiko-AuthToken"]
    keylength = response["X-Radiko-KeyLength"].to_i
    keyoffset = response["X-Radiko-KeyOffset"].to_i
    partialkey = Base64.encode64(auth_key.slice(keyoffset, keylength)).chomp



    ### step2. auth2 する ###
    url = "https://radiko.jp/v2/api/auth2"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    headers = Hash.new()
    headers["X-Radiko-AuthToken"] = auth_token
    headers["X-Radiko-Partialkey"] = partialkey
    headers["X-Radiko-User"] = "dummy_user"
    headers["X-Radiko-Device"] = "pc"

    response = http.get(uri.path, headers)

    unless response.class == Net::HTTPOK || response.class == Net::HTTPFound
      p "auth2_fms につながらない"
      p response.code
      return response
    end



    ### step3. m3u8 を取得する ###
    url = "http://f-radiko.smartstream.ne.jp/" + station_id + "/_definst_/simul-stream.stream/playlist.m3u8"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    headers = Hash.new()
    headers["X-Radiko-AuthToken"] = auth_token

    response = http.get(uri.path, headers)

    unless response.class == Net::HTTPOK || response.class == Net::HTTPFound
      p "m3u8 につながらない"
      p response.code
      if response.code == 403
        p "たぶんエリア外"
      elsif response.code == 404
        p "たぶん station_id が違う"
      end
      return response
    end

    m3u8_url = response.body.match("http.+m3u8")[0]



    ### step4. 録音する ###
    # ffmpeg のパスを確認
    if Configure.where(key: "path_ffmpeg").first==nil ||
       Configure.where(key: "path_ffmpeg").first.value==nil ||
       Configure.where(key: "path_ffmpeg").first.value.empty?
    then
      path_ffmpeg = "ffmpeg"
    else
      path_ffmpeg = Configure.where(key: "path_ffmpeg").first.value
    end

    filename_replaced = filename.gsub(/ /,'\ ') # 半角スペースへの対応
    cmd_ffmpeg = path_ffmpeg
    cmd_ffmpeg += " -loglevel warning"
    cmd_ffmpeg += " -headers 'X-Radiko-Authtoken:#{auth_token}'"
    cmd_ffmpeg += " -i '#{m3u8_url}'"
    cmd_ffmpeg += " -t #{recording_second}"
    cmd_ffmpeg += " -y #{filename_replaced}"

    status = system(cmd_ffmpeg)

    if status
    then
      p "ろくおんせいこう"
    else
      p "ろくおんしっぱい"
      p "params..."
      p "station_id: #{station_id}"
      p "command..."
      p "#{cmd_ffmpeg}"
      FileUtils.rm(filename)
      return 4
    end



    ### step5. タグを編集 ###
    TagLib::MP4::File.open(filename) do |file|
      tag = file.tag
      tag.album = "#{album}" if album.present?
      tag.artist = "#{artist}" if artist.present?
      tag.genre = "#{genre}" if genre.present?
      tag.title = "#{title}" if title.present?
      file.save
    end
  end
end
