module Tzispa
  module Helpers
    module WebCrawler

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def save_image_crawl(source_url, dest_file)
          File.open("#{dest_file}", 'wb') do |fo|
               fo.write open(source_url).read
          end
        end

      end


    end
  end
end
