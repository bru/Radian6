module Radian6
  module SAX
    class PostCounter < Nokogiri::XML::SAX::Document
      attr_reader :count, :total, :error
      def initialize
        @in_count = false
        @in_total = false
        @in_error = false
      end
      def start_element name, attrs = []
        case name
        when "article_count"
          @in_count = true
        when "total_article_count"
          @in_total = true
        when "error"
          @in_error = true
        end
      end

      def end_element name
        case name
        when "article_count"
          @in_count = false
        when "total_article_count"
          @in_total = false
        when "error"
          @in_error
        end
      end

      def characters text
        if @in_count
          @count = text
        elsif @in_total
          @total = text
        elsif @in_error
          @error = text
        end
      end
    end
  end
end