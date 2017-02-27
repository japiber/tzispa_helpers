# frozen_string_literal: true

require 'uri'
require 'tzispa/helpers/mime'

module Tzispa
  module Helpers
    module Services

      class ContentType
        include Tzispa::Helpers::Mime

        attr_reader :response, :default_encoding

        def initialize(response, default_encoding = nil)
          @response = response
          @default_encoding = default_encoding
        end

        # Set the Content-Type of the response body given a media type or file
        # extension.
        def header(type = nil, params = {})
          return response['Content-Type'] unless type || params[:default]
          default = params.delete :default
          mime = mime_type(type) || default
          raise "Unknown media type: #{type}" unless mime
          params = charset mime, params
          build mime.dup, params
        end

        def charset(mime, params)
          unless params.include?(:charset) || mime.include?('charset')
            params[:charset] = params.delete('charset') || default_encoding
          end
          params.delete :charset if mime.include? 'charset'
          params
        end

        def file(type, extension = nil)
          return unless response['Content-Type']
          header type || extension,
                 default: 'application/octet-stream'
        end

        private

        def build(mime, params)
          mime if params.empty?
          mime << (mime.include?(';') ? ', ' : ';')
          mime << params.select { |_, val| val&.match?(/[";,]/) }
                        .map do |key, val|
                          "#{key}=#{val.inspect}"
                        end.join(', ')
          response['Content-Type'] = mime
        end
      end

    end
  end
end
