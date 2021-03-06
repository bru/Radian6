module Radian6
  class Post
    attr_accessor :author, :avatar, :username, :title, :created_at, :updated_at, :id, :body, :source, :permalink
    
    def initialize(params)
      params = {} unless params.is_a? Hash
      @username = params[:username] || ""
      @title    = params[:title]    || ""
      @id       = params[:id]       || ""
      @body     = params[:body]     || ""
      @source   = params[:source].downcase || "" rescue ""
      @permalink= params[:permalink]       || ""
      @author   = params[:author]   || ""
      @avatar   = params[:avatar]   || ""
      @created_at=params[:created_at]  || ""
      @updated_at=params[:updated_at]  || ""
    end
    
    def self.from_xml(xml)
      xml_posts = Nokogiri::XML(xml).root.xpath('//article') rescue []
      posts = []
      xml_posts.each_with_index do |xml_message, index|
        post = self.new({
          :username    => xml_message.xpath('./description/author').text,
          :title       => xml_message.xpath('./description/headline').text,
          :author      => xml_message.xpath('./description/author').text,
          :avatar      => xml_message.xpath('./avatar').text,
          :created_at  => xml_message.xpath('./publish_date').text,
          :updated_at  => xml_message.xpath('./publish_date').text,
          :id          => xml_message.object_id,
          :body        => xml_message.xpath('./description/content').text,
          :source      => xml_message.xpath('./media_provider').text,
          :permalink   => xml_message.xpath('./article_url').text
        })
        posts << post
      end
      return posts
    end
  end
end
