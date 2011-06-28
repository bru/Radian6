module Radian6
  class Topic
    attr_accessor :name, :groups, :id
    
    def initialize(params)
      @name = params[:name]
      @groups   = params[:groups]
      @id       = params[:id]
    end

    def self.system_topics
      # Replace with topic grabbing code!
      t1 = new(:id => 1, :name => 'iPhone', :groups => 'Foos')
      t2 = new(:id => 2, :name => 'Android', :groups => 'Bars')
      t3 = new(:id => 3, :name => 'Nokia', :groups => 'Zoos')
      [t1, t2, t3]
    end

    def self.from_xml(xml)
      doc = Nokogiri::XML(xml)
      xml_topics = doc.root.xpath('//topicFilters/topicFilter')
      topics = []
      xml_topics.each_with_index do |xml_topic, index|
        groups = []
        xml_topic.xpath('./filterGroups/filterGroup').each do |xml_group|
          queries = []
          xml_group.xpath('./filterQueries/filterQuery').each do |xml_query|
            queries << FilterQuery.new({
              :id             => xml_query.xpath('./filterQueryId').text,
              :query          => xml_query.xpath('./query').text,
              :isExcludeQuery => xml_query.xpath('./filterQueryTypeId').text
            })
          end
          
          groups << FilterGroup.new({
            :name     => xml_group.xpath('./name').text,
            :id       => xml_group.xpath('./filterGroupId').text,
            :queries  => queries
          })
        end
        topic = self.new({
          :name     => xml_topic.xpath('./name').text,
          :id       => xml_topic.xpath('./topicFilterId').text,
          :groups   => groups
        })
        topics << topic
      end
      return topics
    end
  end
end