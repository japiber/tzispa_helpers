module Tzispa
  module Helpers
    module Request

      def request_data(fields)
        data = Hash.new
        fields.each { |name|
          data[name.to_sym] = context.request[name]
        }
        data
      end

      def request_upload_file(param:, path:, save_as: nil, keep_ext: true)
        if context.request[param]
          fileext = File.extname(context.request[param][:filename]).downcase.freeze
          filetype = context.request[param][:type].freeze
          save_ext = fileext if keep_ext
          filename = (save_as ? "#{save_as}#{save_ext}" : context.request[param][:filename]).freeze
          tempfile = context.request[param][:tempfile]
          begin
            dest_file = "#{path}#{filename}"
            FileUtils.cp(tempfile.path, dest_file)
            result = { name: filename, ext: fileext, path: dest_file, size: File.size(dest_file), type: filetype }
          rescue
            result = nil
          ensure
            tempfile.close
            tempfile.unlink
          end
        else
          result = nil
        end
        result
      end


    end
  end
end
