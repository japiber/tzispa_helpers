# frozen_string_literal: true

require 'tzispa/utils/string'

module Tzispa
  module Helpers
    module Request

      using Tzispa::Utils::TzString

      def request_data(fields)
        {}.tap do |data|
          fields.each do |name|
            macro_field = name.split('@:')
            macro = macro_field.first.to_sym if macro_field.length == 2
            field = macro_field.length == 2 ? macro_field.last : macro_field.first
            build_field field, macro, data
          end
        end
      end

      def request_data_object(data_object:, fields:)
        data_object.tap do |data|
          fields.each do |name|
            macro_field = name.split('@:')
            macro = macro_field.first.to_sym if macro_field.length == 2
            field = macro_field.length == 2 ? macro_field.last : macro_field.first
            build_field field, macro, data
          end
        end
      end

      def request_file_upload(request_file:, destination_path:, save_as: nil, keep_ext: true)
        return unless request_file
        fileext = File.extname(request_file[:filename]).downcase
        filetype = request_file[:type]
        save_ext = fileext if keep_ext
        filename = (save_as ? "#{save_as}#{save_ext}" : request_file[:filename])
        tempfile = request_file[:tempfile]
        dest_file = "#{destination_path}/#{filename}"
        begin
          FileUtils.mkdir_p(destination_path) unless File.exist?(destination_path)
          FileUtils.cp tempfile.path, dest_file
        ensure
          tempfile.close
          tempfile.unlink
        end
        { name: filename, ext: fileext, path: dest_file,
          size: ::File.size(dest_file), type: filetype }
      end

      def build_field(field, macro, data)
        field.split(':').tap do |src, dest|
          dest ||= src
          value = if String == request[src]
                    String.unescape_html(request[src])
                  else
                    request[src]
                  end
          value = macro ? send(macro, value) : value
          if data.is_a? ::Hash
            data[dest.to_sym] = value
          else
            data.send "#{dest}=".to_sym, value
          end
        end
      end

    end
  end
end
