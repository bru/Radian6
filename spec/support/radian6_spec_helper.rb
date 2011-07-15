module Radian6SpecHelper
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
