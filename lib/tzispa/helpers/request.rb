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
          begin
            dest_file = "#{destination_path}/#{filename}"
            FileUtils.cp tempfile.path, dest_file
            result = { name: filename, ext: fileext, path: dest_file, size: ::File.size(dest_file), type: filetype }
          rescue => err
            context.logger.fatal(err) if context
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
