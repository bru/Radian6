require 'rubygems'
require 'active_support'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'digest/md5'


module Radian6
  class API
    attr_reader :auth_appkey, :auth_token
    def initialize(username, password, app_key, sandbox=false, debug=false)
      @auth_appkey = app_key
      @debug = debug
    
      if sandbox
        @endpoint = "http://devapi.radian6.com/socialcloud/v1/"
      else
        @endpoint = "http://api.radian6.com/socialcloud/v1/"
      end
      
      authenticate(username, password)
      return self
    end
  
    def topics(cache=false)
      if (cache)
        xml = File.read('./fixtures/topics.xml')
      else
        xml = api_get( "topics", { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })
      end
      return Radian6::Topic.from_xml(xml)
    end
  
    def fetchRecentTopicPosts(hours=1,topics=[62727],media=[1,2,4,5,8,9,10,11,12,13,16],start_page=0,page_size=1000,dump_file=false)
      path = "data/topicdata/recent/#{hours}/#{topics.join(',')}/#{media.join(',')}/#{start_page}/#{page_size}"
      xml = api_get(path, { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })     
      return Radian6::Post.from_xml(xml)
    end
  
    def fetchRangeTopicPosts(range_start,range_end,topics=[62727],media=[1,2,4,5,8,9,10,11,12,13,16],start_page=0,page_size=1000,dump_file=false)
      # BEWARE: range_start and range_end should be UNIX epochs in milliseconds, not seconds
      path = "data/topicdata/range/#{range_start}/#{range_end}/#{topics.join(',')}/#{media.join(',')}/#{start_page}/#{page_size}"
      log "\tGetting page #{start_page} for range #{range_start} to #{range_end} at #{Time.now}"
      xml = api_get(path, { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token }) 
      
      if dump_file
        log "\tDumping to file #{dump_file} at #{Time.now}"
        f = File.new(dump_file, "w")
        f.write(xml)
        f.close

        counter = Radian6::SAX::PostCounter.new 
        parser = Nokogiri::XML::SAX::Parser.new(counter)
        parser.parse(xml)
        log "\tFinished parsing the file at #{Time.now}"
        raise counter.error if counter.error
        return counter
      else
        return Radian6::Post.from_xml(xml)
      end
    end
  
    protected
  
    def authenticate(username, password) 
      md5_pass = Digest::MD5::hexdigest(password)
      xml = api_get("auth/authenticate", { 'auth_user' => username, 'auth_pass' => md5_pass})
      doc = Nokogiri::XML(xml)
      @auth_token = doc.xpath('//auth/token').text
    end
    
    def log(string)
      puts "LOG:" + string if @debug
    end
  
    def api_get(method, args={})
          
      unless method == "auth/authenticate"
        args['auth_appkey'] = @auth_appkey
        args['auth_token']  = @auth_token
      end
      url = URI.parse(@endpoint)
      log "GET #{@endpoint + method}"
    
      res = Net::HTTP.start(url.host, url.port ) do |http|
        http.open_timeout = 3600
        http.read_timeout = 3600
        http.get(@endpoint + method, args)
      end
      res.body # maybe handle errors too...
    end
    
  end
end