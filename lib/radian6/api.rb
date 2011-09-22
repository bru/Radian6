require 'rubygems'
require 'active_support'
require 'nokogiri'
require 'net/http'
require 'uri'
require 'digest/md5'


module Radian6
  class API
    class HarvestError < StandardError; end
    attr_reader :auth_appkey, :auth_token
    def initialize(username, password, app_key, opts={})
      @auth_appkey = app_key
      opts = { :sandbox => false, :debug => false, :async => false }.merge(opts)
      @debug = opts[:debug]
      @async = opts[:async]
      @proxy = opts[:proxy]
      if opts[:sandbox]
        @endpoint = "http://sandboxapi.radian6.com/socialcloud/v1/"
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
        log("App Key: #{@auth_appkey.inspect}")
        log("Auth Token: #{@auth_token.inspect}")
        xml = api_get( "topics", { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })
      end
      log("Received XML\n#{xml.inspect}")
      return Radian6::Topic.from_xml(xml)
    end

    def fetchRecentTopicPosts(hours=1,topics=[62727],media=[1,2,4,5,8,9,10,11,12,13,16],start_page=0,page_size=1000,dump_file=false)
      path = "data/topicdata/recent/#{hours}/#{topics.join(',')}/#{media.join(',')}/#{start_page}/#{page_size}"
      xml = api_get(path, { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })     
      return Radian6::Post.from_xml(xml)
    end

    def fetchRangeTopicPosts(range_start,range_end,topics=[62727],media=[1,2,4,5,8,9,10,11,12,13,16],start_page=0,page_size=1000,dump_file=false)
      # BEWARE: range_start and range_end should be UNIX epochs in milliseconds, not seconds
      xml = fetchRangeTopicPostsXML(range_start, range_end, topics, media, start_page, page_size)

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

    def fetchRangeTopicPostsXML(range_start, range_end, topics=[], media=[1,2,4,5,8,9,10,11,12,13,16], start_page=1, page_size=1000)
      # BEWARE: range_start and range_end should be UNIX epochs in milliseconds, not seconds
      path = "data/topicdata/range/#{range_start}/#{range_end}/#{topics.join(',')}/#{media.join(',')}/#{start_page}/#{page_size}?includeFullContent=1"
      log "\tGetting page #{start_page} for range #{range_start} to #{range_end} at #{Time.now}"
      xml = api_get(path, { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })
      return xml
    end

    def fetchMediaTypes
      path = "lookup/mediaproviders"
      xml = api_get(path, { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })
      return xml
    end

    def eachRangeTopicPostsXML(range_start, range_end, topics=[62727], media=[1,2,4,5,8,9,10,11,12,13,16], page_size=1000)
      page = 1
      fetched_article_count = 0
      botched = 0
      total_count = 1
      begin
        xml = fetchRangeTopicPostsXML(range_start, range_end, topics, media, page, page_size)

        counter = Radian6::SAX::PostCounter.new
        parser  = Nokogiri::XML::SAX::Parser.new(counter)
        parser.parse(xml)
        raise counter.error if counter.error
        total_count = counter.total
        fetched_article_count = (page -1) * page_size + counter.count
        yield page, xml, counter

        page += 1
        botched = 0
      rescue => e
        # TODO: rescue exceptions from malformed xml
        # raise if botched > 5
        # else log offending request and try again
        botched += 1
        if botched < 5
          File.open(File.join(File.dirname(__FILE__), "..", "..", "log", 
              "botched-#{range_start}-#{range_end}-#{topics.join(',')}-#{page}.#{Time.new}.error"), "w") do |f|
            f.write("#{e.class}\n#{e.message}\n\n")
            f.write("-----------------------------")
            f.write("BACKTRACE:\n#{e.backtrace}\n")
            f.write("-----------------------------")
            f.write(xml)
          end
        else
          raise HarvestError
        end
        raise counter.error if counter.error
      end while total_count > fetched_article_count
    end

    def fetchRangeConversationCloudData(range_start, range_end, topics=[62727], media=[1,2,4,5,8,9,10,11,12,13,16], segmentation=0)
      path = "data/tagclouddata/#{range_start}/#{range_end}/#{topics.join(',')}/#{media.join(',')}/#{segmentation}"
      api_get(path, { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })
    end

    def fetchInfluencerData(topics=[], show_sentiment = 0, show_engagement = 0)
      path = "data/influencerdata/#{topics.join(",")}/#{show_sentiment}/#{show_engagement}/"
      api_get(path, { 'auth_appkey' => @auth_appkey, 'auth_token' => @auth_token })
    end
  
    protected
  
    def authenticate(username, password) 
      log("Username -> #{username.inspect}")
      log("Password -> #{password.inspect}")
      md5_pass = Digest::MD5::hexdigest(password)
      xml = api_get("auth/authenticate", { 'auth_user' => username, 'auth_pass' => md5_pass})
      log("Received XML\n#{xml.inspect}")
      doc = Nokogiri::XML(xml)
      @auth_token = doc.xpath('//auth/token').text
    end
    
    def log(string)
      puts "#{self.class}: #{string}" if @debug
    end
  
    def api_get(method, headers={})
      if @async
        get_async(method, headers)
      else
        get_sync(method, headers)
      end
    end

    def get_async(method, headers={})
      options = { 
        :connect_timeout => 3600,
        :inactivity_timeout => 3600,
      }
      options[:proxy] = { :host => @proxy.host, :port => @proxy.port.to_i } if @proxy

      unless method == "auth/authenticate"
        headers['auth_appkey'] = @auth_appkey
        headers['auth_token']  = @auth_token
      end
      http = EventMachine::HttpRequest.new(@endpoint + method, options ).get :head => headers
      http.response 
    end

    def get_sync(method, args={})
      unless method == "auth/authenticate"
        args['auth_appkey'] = @auth_appkey
        args['auth_token']  = @auth_token
      end
      
      url = URI.parse(@endpoint + method)
      
      protocol = @proxy.nil? ? Net::HTTP : Net::HTTP::Proxy(@proxy.host, @proxy.port)

      res = protocol.start(url.host, url.port ) do |http|
        http.open_timeout = 3600
        http.read_timeout = 3600
        log "  GET #{url.request_uri}"
        http.get(url.request_uri, args)
      end
      res.body # maybe handle errors too...
    end
    
  end
end
