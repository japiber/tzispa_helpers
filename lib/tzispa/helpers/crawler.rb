module Tzispa
  module Helpers
    module Crawler


      def crawler_save_file(source_url, dest_file)
        File.open("#{dest_file}", 'wb') do |fo|
             fo.write open(source_url).read
        end
      end


    end
  end
end
