# coding: utf-8
require 'net/http'
require 'net/https'
require 'uri'
require 'open-uri'
require 'base64'


class ProgramRecorder

  #
  # station_id : string
  # start_date : date
  # recording_second : integer
  # mail_address : string(optional)
  # password : string(optional)
  def self.record(station_id, recording_second, filename,
                  mail_address: nil, password: nil)
    playerurl = "http://radiko.jp/player/swf/player_4.1.0.00.swf"
    
    # まずプレミアムでログインできるかどうかを試してみる.
    if mail_address == nil || password == nil
    then
      premium = false
    else
      premium = true
      url = "https://radiko.jp/ap/member/login/login"
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.request_uri)
      req.delete("Content-Type")
      req.body = "mail=#{mail_address}&pass=#{password}"
      response = https.request(req)
      unless response.class == Net::HTTPOK || response.class == Net::HTTPFound
        p "にんしょうしっぱい"
        return response
      end
      cookie={}
      response.get_fields('Set-Cookie').each{|str|
        k,v = str[0...str.index(';')].split('=')
        cookie[k] = v
      }

      #return cookie
      
      # ログインできてるかチェック
      url = "https://radiko.jp/ap/member/webapi/member/login/check"
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(uri.request_uri)
      req.delete("Content-Type")
      req["pragma"] = "no-cache"
      req["Cahce-Control"] = "no-cache"
      req["X-Radiko-App"] = "pc_1"
      req["X-Radiko-App-Version"] = "2.0.1"
      req["X-Radiko-User"] = "test-stream"
      req["X-Radiko-Device"] = "pc"
      req["Cookie"] = cookie.map{|k,v| "#{k}=#{v}" }.join(";")
      req.body = '\r\n'
      response = https.request(req)
      unless response.class == Net::HTTPOK || response.class == Net::HTTPFound
        p "にんしょうしっぱい"
        return response
      end
        
    end
    
    ### step0. 保存用ディレクトリの存在の確認 ###
    path_storedir = Pathname.new(Configure.where(key: "storedir").first.value)
    unless File.exist?(path_storedir.to_s)
    then
      p "ディレクトリがない"
      if Dir.mkdir(path_storedir.to_s, 0755) != 0
      then
        p "ディレクトリつくれない"
        return 1
      end
    end
      
    ### step1. 持ってなかったら player を手に入れる ###
    path_playerfile = path_storedir + "player.swf"
    unless File.exist?(path_playerfile.to_s)
    then
      begin
        p "player ファイルがない"
        open(path_playerfile.to_s, 'wb'){|saved_file|
          open(playerurl, 'rb'){|read_file|
            saved_file.write(read_file.read)
          }
        }
        p "player ファイルつくった"
      rescue
        p "player ファイルつくれない"
        return 2
      end
    else
      p "player ファイルある"
    end
    
    ### step2. keydata を抽出する ###
    path_keyfile = path_storedir + "authkey.png"
    unless File.exist?(path_keyfile.to_s)
      p "auhtykey.png がない"
      if Configure.where(key: "path_swfextract").first==nil ||
         Configure.where(key: "path_swfextract").first.value.empty?
      then
        path_swfextract = "swfextract"
      else
        path_swfextract = Configure.where(key: "path_swfextract").first.value
      end
      if system("#{path_swfextract} -b 14 #{path_playerfile} -o #{path_keyfile}")
      then
        p "authkey.png つくった"
      else
        p "authkey.png つくれない"
        return 3
      end
      else
      p "authkey.png がある"
    end

    ### step3. auth1_fms して paritalkey を抽出する ###
    url = "https://radiko.jp/v2/api/auth1_fms"
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.request_uri)
    req.delete("Content-Type")
    req["pragma"] = "no-cache"
    req["X-Radiko-App"] = "pc_1"
    req["X-Radiko-App-Version"] = "2.0.1"
    req["X-Radiko-User"] = "test-stream"
    req["X-Radiko-Device"] = "pc"
    req["Cookie"] = cookie.map{|k,v| "#{k}=#{v}" }.join(";") if premium
    req.body = '\r\n'
    req.body = '\r\n'
    response = https.request(req)
      unless response.class == Net::HTTPOK || response.class == Net::HTTPFound
      p "auth1_fms につながらない"
      return response
    end
    auth1_params = Hash[response.body.match(/^(.+=.+\r\n)+/).to_s.scan(/(.+)=(.+)\r\n/)]
    authtoken = auth1_params["X-Radiko-AuthToken"]
    keylength = auth1_params["X-Radiko-KeyLength"].to_i
    keyoffset = auth1_params["X-Radiko-KeyOffset"].to_i
    partialkey =
      Base64.encode64(File.binread(path_keyfile.to_s, keylength, keyoffset)).chomp

    ### step4. auth2_fms する ###
    url = "https://radiko.jp/v2/api/auth2_fms"
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.request_uri)
    req.delete("Content-Type")
    req["pragma"] = "no-cache"
    req["X-Radiko-App"] = "pc_1"
    req["X-Radiko-App-Version"] = "2.0.1"
    req["X-Radiko-User"] = "test-stream"
    req["X-Radiko-Device"] = "pc"
    req["X-Radiko-Authtoken"] = authtoken
    req["X-Radiko-Partialkey"] = partialkey
    req["Cookie"] = cookie.map{|k,v| "#{k}=#{v}" }.join(";") if premium
    req.body = '\r\n'
    req.body = '\r\n'
    response = https.request(req)
      unless response.class == Net::HTTPOK || response.class == Net::HTTPFound
      p "auth2_fms につながらない"
      return response
    end

    ### step5. stream-url を取得する ###
    url = "http://radiko.jp/v2/station/stream_multi/#{station_id}.xml"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(req)
    stream_urls = Hash[response.body.match(/(<item.+<\/item>\s*)+/).to_s.
                        scan(/<.+areafree=\"(0|1)\">(.+)<\/.+>/)]
    if premium
    then
      stream_url = stream_urls["1"]
    else
      stream_url = stream_urls["0"]
    end

    ### step6. stream-url を分割する ###
    url_parts = stream_url.scan(%r!(.+://.+)/(.+)/(.+)!)[0].to_a
    
    ### step7. 録音 ###
    if Configure.where(key: "path_rtmpdump").first==nil ||
       Configure.where(key: "path_rtmpdump").first.value.empty?
    then
      path_rtmpdump = "rtmpdump"
    else
      path_rtmpdump = Configure.where(key: "path_rtmpdump").first.value
    end
    filename_replaced = filename.gsub(/ /,'\ ') # 半角スペースへの対応
    cmd_rtmpdump = path_rtmpdump
    cmd_rtmpdump += " --rtmp #{url_parts[0]}"
    cmd_rtmpdump += " --app #{station_id}/#{url_parts[1]}"
    cmd_rtmpdump += " --playpath #{url_parts[2]}"
    cmd_rtmpdump += " --swfVfy #{playerurl}"
    cmd_rtmpdump += " --conn S:\"\" --conn S:\"\" --conn S:\"\" --conn S:#{authtoken}"
    cmd_rtmpdump += " --live"
    cmd_rtmpdump += " --stop #{recording_second}"
    cmd_rtmpdump += " --flv \'#{filename}\'"

    status = system(cmd_rtmpdump)

    if status
      p "ろくおんせいこう"
    else
      p "ろくおんしっぱい"
      p "params..."
      p "station_id: #{station_id}"
      p "command..."
      p "#{cmd_rtmpdump}"
    end
  end
end
  
