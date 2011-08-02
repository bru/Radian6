module Radian6
  class Topic
    attr_accessor :name, :groups, :id
    
    def initialize(params)
      params = {} unless params.is_a? Hash
      @name = params[:name] || ""
      @groups   = params[:groups] || ""
      @id       = params[:id] || ""
    end

    def self.from_xml(xml)
      xml_topics = Nokogiri::XML(xml).root.xpath('//topicFilters/topicFilter') rescue []
      topics = []
      xml_topics.each do |xml_topic|
        topics << parse_topic(xml_topic)
      end
      return topics
    end
    private

    def self.parse_topic(xml_topic)
      groups = []
      xml_topic.xpath('./filterGroups/filterGroup').each do |xml_group|
        groups << parse_group(xml_group)
      end
      self.new({
        :name     => xml_topic.xpath('./name').text,
        :id       => xml_topic.xpath('./topicFilterId').text,
        :groups   => groups
      })
    end

    def self.parse_group(xml_group)
      queries = []
      xml_group.xpath('./filterQueries/filterQuery').each do |xml_query|
        queries << FilterQuery.new({
          :id             => xml_query.xpath('./filterQueryId').text,
          :query          => xml_query.xpath('./query').text,
          :isExcludeQuery => xml_query.xpath('./filterQueryTypeId').text
        })
      end

      FilterGroup.new({
        :name     => xml_group.xpath('./name').text,
        :id       => xml_group.xpath('./filterGroupId').text,
        :queries  => queries
      })
    end
  end
end
