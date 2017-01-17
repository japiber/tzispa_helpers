# frozen_string_literal: true
require 'tzispa/utils/string'

module Tzispa
  module Helpers
    module Request
      include Tzispa::Utils::String

      def request_data(fields)
        Hash.new.tap { |data|
          fields.each { |name|
            macro_field = name.split('@:')
            macro = macro_field.first.to_sym if macro_field.length == 2
            field = macro_field.length == 2 ? macro_field.last : macro_field.first
            field.split(':').tap { |fld|
              src = fld.first
              dest = fld.last
              value = String == context.request[src] ? unescape_html(context.request[src]) : context.request[src]
              data[dest.to_sym] = macro ? send(macro, value) : value
            }
          }
        }
      end

      def request_data_object(data_object:, fields:)
        data_object.tap { |data|
          fields.each { |name|
            macro_field = name.split('@:')
            macro = macro_field.first.to_sym if macro_field.length == 2
            field = macro_field.length == 2 ? macro_field.last : macro_field.first
            field.split(':').tap { |fld|
              src = fld.first
              dest = fld.last
              value = String == context.request[src] ? unescape_html(context.request[src]) : context.request[src]
              data.send "#{dest}=".to_sym, macro ? send(macro, value) : value
            }
          }
        }
      end

      def request_file_upload(request_file:, destination_path:, save_as: nil, keep_ext: true)
        if request_file
          fileext = File.extname(request_file[:filename]).downcase
          filetype = request_file[:type]
          save_ext = fileext if keep_ext
          filename = (save_as ? "#{save_as}#{save_ext}" : request_file[:filename])
          tempfile = request_file[:tempfile]
          dest_file = "#{destination_path}/#{filename}"
          begin
            FileUtils.mkdir_p(destination_path) unless File.exists?(destination_path)            
            FileUtils.cp tempfile.path, dest_file
          ensure
            tempfile.close
            tempfile.unlink
          end
          { name: filename, ext: fileext, path: dest_file, size: ::File.size(dest_file), type: filetype }
        end
      end


    end
  end
end
