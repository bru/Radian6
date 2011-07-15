require 'spec_helper'
require 'radian6'

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

  context "after initialization" do
    before do 
      @r6 = Radian6::API.new "username", "password", "123456789";
    end

    describe "#topics" do
      before do
        stub_request(:get, /.*api.radian6.com.+/).
          to_return(:status => 200, :body => topics_xml)
      end

      it "should request topics" do
        @r6.topics
        WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/topics").
          with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})
      end
    
      it "should return a collection" do
        @r6.topics.should respond_to :each
      end
    end
    
    describe "fetchRecentTopicPosts" do
      before do
        @topics = [123456]
        stub_request(:get, /.*api.radian6.com.+/).
        to_return(:status => 200, :body => recent_xml)
      end

      it "should make the correct request" do
         @r6.fetchRecentTopicPosts 1, @topics, [1]
         WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/data/topicdata/recent/1/123456/1/0/1000").
           with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})
      end
      
      it "should return a collection" do
        @r6.fetchRecentTopicPosts(1, @topics, [1]).should respond_to :each
      end
      
      it "should return radian6 posts" do
        Radian6::Post.should_receive(:from_xml)
        @r6.fetchRecentTopicPosts(1, @topics, [1])
      end
     end
     
    describe "fetchRangeTopicPostsXML" do
      before do
        @topics = [123456]
        stub_request(:get, /.*api.radian6.com.+/).
           to_return(:status => 200, :body => range_xml)
      end
      
      it "should make the correct request" do
        @r6.fetchRangeTopicPostsXML "1308738914000", "1308738964000", @topics, [1]
        WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/data/topicdata/range/1308738914000/1308738964000/123456/1/0/1000").
          with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})
      end
      
      it "should not return radian6 posts" do
        Radian6::Post.should_not_receive(:from_xml)
        @r6.fetchRangeTopicPostsXML(1, @topics, [1])
      end
      
      it "should return xml" do
        @r6.fetchRangeTopicPostsXML("1308738914000", "1308738964000", @topics, [1]).should == range_xml
      end
    end
    
    describe "eachRangeTopicPostsXML" do
      before do
        @topics = [123456]
      end
      context "when posts span multiple pages" do 
        it "should loop over all the pages" do
          stub_request(:get, /.*api.radian6.com.+\/[012]\/10/).
            to_return(:status => 200, :body => pages_xml(10, 33))
          stub_request(:get, /.*api.radian6.com.+\/3\/10/).
            to_return(:status => 200, :body => pages_xml(3, 33))

          counter = 0
          @r6.eachRangeTopicPostsXML("1308738914000", "1308738964000", @topics, [1], 10) do |page, xml|
            WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/data/topicdata/range/1308738914000/1308738964000/123456/1/#{counter}/10").
              with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})

            page.should == counter
            if counter == 3
              xml.should == pages_xml(3, 33)
            else
              xml.should == pages_xml(10, 33)
            end
            counter += 1
          end

          counter.should == 4
        end
      end
      context "when all posts fit in one page" do
        it "should make just one call" do
          stub_request(:get, /.*api.radian6.com.+\/0\/10/).
            to_return(:status => 200, :body => pages_xml(10, 10))

          counter = 0
          @r6.eachRangeTopicPostsXML("1308738914000", "1308738964000", @topics, [1], 10) do |page, xml|
            WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/data/topicdata/range/1308738914000/1308738964000/123456/1/#{counter}/10").
              with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})
            counter += 1
          end
          counter.should == 1
        end
      end
      context "when there are no posts" do
         it "should loop just once" do
           stub_request(:get, /.*api.radian6.com.+\/0\/20/).
             to_return(:status => 200, :body => pages_xml(0, 0))

           counter = 0
           @r6.eachRangeTopicPostsXML("1308738914000", "1308738964000", @topics, [1], 20) do |page, xml|
             WebMock.should have_requested(:get, "http://api.radian6.com/socialcloud/v1/data/topicdata/range/1308738914000/1308738964000/123456/1/#{counter}/20").
               with(:headers => {'Auth-Appkey' => '123456789', 'Auth-Token' => 'abcdefghi'})

             page.should == 0
             xml.should == pages_xml(0, 0)
             counter += 1
           end

           counter.should == 1
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

  def pages_xml(article_count=10, total_article_count=100)
    "<radian6_RiverOfNews_export>
      <article_count>#{article_count}</article_count>
      <total_article_count>#{total_article_count}</total_article_count>
    </radian6_RiverOfNews_export>"
  end
end