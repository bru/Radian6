require 'spec_helper'
require 'radian6'

# Specs in this file have access to a helper object that includes
# the HomeHelper. For example:
#
# describe HomeHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe Radian6::API do
  before do
    stub_request(:get, "http://api.radian6.com/socialcloud/v1/auth/authenticate").
      to_return(:status => 200, :body => auth_xml)
  end
  
  describe "initialization" do
    it "should authenticate user" do
      r6 = Radian6::API.new "username", "password", "123456789"
      
      WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/auth/authenticate").
        with(:headers => {'Auth-Pass' => '5f4dcc3b5aa765d61d8327deb882cf99', 'Auth-User' => 'username'})
      
      r6.should_not be_nil
      r6.auth_token.should == "abcdefghi"
      r6.auth_appkey.should == "123456789"
    end
  end
  
  describe "once initialized" do
    before do
      @r6 = Radian6::API.new "username", "password", "123456789";
    end
    
    it "should return a list of topics" do
      stub_request(:get, "http://api.radian6.com/socialcloud/v1/topics").
        to_return(:status => 200, :body => topics_xml)
      
      topics = @r6.topics
      
      WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/topics").
        with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})
      
      topics.length.should == 1
      
      topic = topics.first
      topic.should be_a Radian6::Topic
      topic.name.should == "FILTER TEST"
      topic.id.should == "111111"
      topic.groups.length.should == 2
      
      group = topic.groups.first
      group.should be_a Radian6::FilterGroup
      group.name.should == "Group 2 test"
      group.id.should == "222222"
      group.queries.length.should == 2
      
      query = group.queries.first
      query.should be_a Radian6::FilterQuery
      query.id.should == "333333"
      query.query.should == '"apple" AND "banana"'
      query.isExcludeQuery.should == '0'
    end
    
    describe "given a topic" do
      before do
        @topics = [123456]
      end
      
      it "should return a list of recent posts" do
        stub_request(:get, "http://api.radian6.com/socialcloud/v1/data/topicdata/recent/1/123456/1/0/1000").
          to_return(:status => 200, :body => recent_xml)
        
        posts = @r6.fetchRecentTopicPosts 1, @topics, [1]
        
        WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/data/topicdata/recent/1/123456/1/0/1000").
          with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})
        
        posts.length.should == 2
        
        post = posts.first
        post.should be_a Radian6::Post
        post.username.should == "author"
        post.title.should == "TEST HEADLINE 1"
        post.created_at.should == "Jun 22, 2011 11:35 AM"
        post.updated_at.should == "Jun 22, 2011 11:35 AM"
        post.body.should == "article content"
        post.source.should == "twitter"
        post.permalink.should == "http://example.com/111111"
        # TODO test post.id
      end
      
      it "should return a list of posts in a range" do
        range_url = "http://api.radian6.com/socialcloud/v1/data/topicdata/range/1308738914000/1308738964000/123456/1/0/1000"
        stub_request(:get, range_url).
          to_return(:status => 200, :body => range_xml)
        
        posts = @r6.fetchRangeTopicPosts "1308738914000", "1308738964000", @topics, [1]
        
        WebMock.should have_requested(:get, range_url).
          with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})
        
        posts.length.should == 2
        
        post = posts.first
        post.should be_a Radian6::Post
        post.username.should == "author"
        post.title.should == "TEST HEADLINE 1"
        post.created_at.should == "Jun 22, 2011 11:35 AM"
        post.updated_at.should == "Jun 22, 2011 11:35 AM"
        post.body.should == "article content"
        post.source.should == "twitter"
        post.permalink.should == "http://example.com/111111"
        # TODO test post.id
      end
    end
  end
end

def auth_xml
  "<auth><token>abcdefghi</token></auth>"
end

def topics_xml
  '<topicFilters>
    <topicFilter>
      <name><![CDATA[FILTER TEST]]></name>
      <topicFilterId>111111</topicFilterId>
      <filterGroups>
        <filterGroup>
          <filterGroupId>222222</filterGroupId>
          <name><![CDATA[Group 2 test]]></name>
          <filterQueries>
            <filterQuery>
              <query><![CDATA["apple" AND "banana"]]></query>
              <filterQueryId>333333</filterQueryId>
              <filterQueryTypeId>0</filterQueryTypeId>
            </filterQuery>
            <filterQuery>
              <query><![CDATA["coconut" AND "date"]]></query>
              <filterQueryId>444444</filterQueryId>
              <filterQueryTypeId>0</filterQueryTypeId>
            </filterQuery>
          </filterQueries>
        </filterGroup>
        <filterGroup>
          <filterGroupId>555555</filterGroupId>
          <name><![CDATA[Group 5 test]]></name>
          <filterQueries>
            <filterQuery>
              <query><![CDATA["elderberry" AND "fig"]]></query>
              <filterQueryId>666666</filterQueryId>
              <filterQueryTypeId>0</filterQueryTypeId>
            </filterQuery>
          </filterQueries>
        </filterGroup>
    </filterGroups>
    </topicFilter>
  </topicFilters>'
end

def recent_xml
  '<radian6_RiverOfNews_export>
    <article ID="111111">
      <description charset="UTF-8">
        <headline><![CDATA[TEST HEADLINE 1]]></headline>
        <author fbid="-1"><![CDATA[author]]></author>
        <content><![CDATA[article content]]></content>
      </description>
      <article_url><![CDATA[http://example.com/111111]]></article_url>
      <media_provider id="10">TWITTER</media_provider>
      <publish_date epoch="1308738914000">Jun 22, 2011 11:35 AM</publish_date>
    </article>
    <article ID="222222">
      <description charset="UTF-8">
        <headline><![CDATA[TEST HEADLINE 2]]></headline>
        <author fbid="-1"><![CDATA[author]]></author>
        <content><![CDATA[article content]]></content>
      </description>
      <article_url><![CDATA[http://example.com/222222]]></article_url>
      <media_provider id="10">TWITTER</media_provider>
      <publish_date epoch="1308738914000">Jun 22, 2011 11:35 AM</publish_date>
    </article>
  </radian6_RiverOfNews_export>'
end
alias :range_xml :recent_xml