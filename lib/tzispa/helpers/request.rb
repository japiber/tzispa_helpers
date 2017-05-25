# frozen_string_literal: true

require 'tzispa/utils/string'
require 'json'
require_relative 'macro_field'

module Tzispa
  module Helpers
    module Request

      include Tzispa::Helpers::MacroField

      def request_json(key = nil)
        return unless request.content_type&.include?('application/json')
        body = request.body.gets
        key ? JSON.parse(body)[key] : JSON.parse(body)
      end

      def request_json_object(key = nil, data_object:, fields:, json: nil)
        process_macros request_json(key), fields, data_object: data_object,
                                                  json: json
      end

      def request_data(fields)
        process_macros request, fields
      end

      def request_data_object(data_object:, fields:, json: nil)
        process_macros request, fields, data_object: data_object,
                                        json: json
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

    end
  end
end
