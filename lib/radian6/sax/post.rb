module Radian6
  module SAX
    class Post < Nokogiri::XML::SAX::Document
      attr_reader :posts
      def initialize
        @post_elem = false
        @current_post = {}
        @posts = []
        @path = []
        @xpaths = {
            :prefix => "radian6_RiverOfNews_export/article/", 
            :paths  => {'description/author'    => "username",
                        'description/headline'  => "title",
                        'description/author'    => "author",
                        'avatar'                => "avatar",
                        'publish_date'          => "created_at",
                        'description/content'   => "body",
                        'media_provider'        => "source",
                        'article_url'           => "permalink"
                      }
          }
      end
      
      def start_element name, attrs = []
        @path << name
        if is_resource_elem?
          @post_elem = find_resource_elem(name)
        end
        if name == "article"
          attrs.each do |a|
            @current_post[:id] = a[1] if a[0].to_s.downcase == "id"
          end
        end
      end
    
      def end_element name
        @path.pop
        @post_elem = false
        if name == "article"
          post = Radian6::Post.new(@current_post)
          new_post(post)
          @current_post = {}
        end
        if name == "radian6_RiverOfNews_export"
          end_of_file
        end
      end

      def characters text
        update_post(text)
      end
      
      def cdata_block text
        update_post(text)
      end
      
      def update_post(text)
        if @post_elem
          @current_post[@post_elem] = text
        end
      end        
      
      def new_post(post)
        @posts << post
      end
      
      def end_of_file
        true
      end
      
      def is_resource_elem?
        xpaths.include?(current_path)
      end
      
      def find_resource_elem(name)
        xpaths_map[current_path].to_sym
      end
      
      def current_path
        @path.join("/")
      end
      
      def xpaths
        @expanded_paths ||= @xpaths[:paths].keys.map { |x| @xpaths[:prefix] + x }
      end
      
      def xpaths_map
        return @expanded_paths_map if @expanded_paths_map
        
        @expanded_paths_map = {}
        @xpaths[:paths].keys.each do |path|
          @expanded_paths_map[@xpaths[:prefix] + path] = @xpaths[:paths][path]
        end
        return @expanded_paths_map
      end
      
    end
  end
end
