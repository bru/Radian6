require 'nokogiri'

module Radian6
  module SAX
    class PostCounter < Nokogiri::XML::SAX::Document
      attr_reader :count, :total, :error, :last_timestamp
      def initialize
        @in_count = false
        @in_total = false
        @in_error = false
      end
      def start_element name, attrs = []
        unless done?
          case name
          when "article_count"
            @in_count = true
          when "total_article_count"
            @in_total = true
          when "error"
            @in_error = true
          when "publish_date"
            fetch_timestamp(attrs)
          end
        end
      end

      def end_element name
        unless done?
          case name
          when "article_count"
            @in_count = false
          when "total_article_count"
            @in_total = false
          when "error"
            @in_error = false
          end
        end
      end

      def characters text
        unless done?
          if @in_count
            @count = text.to_i
          elsif @in_total
            @total = text.to_i
          elsif @in_error
            @error = text
          end
        end
      end

      def fetch_timestamp(attrs = [])
        @last_timestamp ||= attrs.select { |key, value| key == "epoch" }.first[1].to_i
      end

      def done?
        (@count.nil? || @total.nil? || @last_timestamp.nil?) ? false : true
      end
    end
  end
end
