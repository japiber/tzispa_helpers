# frozen_string_literal: true

require 'uri'

module Tzispa
  module Helpers
    module Services

      class SendFile
        attr_reader :response, :opts, :path

        def initialize(response, path, opts)
          @response = response
          @opts = opts
          @path = path
        end

        def content_disposition(filename = nil, disposition = 'attachment')
          disposition = String.new << disposition.to_s
          if filename
            escaped = URI.escape(filename)
            disposition << "; filename=\"#{escaped}\""
            disposition << "; filename*=UTF-8''#{escaped}"
          end
          response['Content-Disposition'] = disposition
        end

        def send(result)
          prepare
          response.status = result[0]
          if response.status.between? 200, 299
            headers_set result[1]
            response.body = result[2]
          end
          response
        end

        private

        def prepare
          content_headers
          disposition = opts[:disposition]
          filename    = opts[:filename]
          disposition = 'attachment' if disposition.nil? && filename
          filename    = path         if filename.nil?
          content_disposition filename, disposition
        end

        def headers_set(headers)
          headers.each { |k, v| response.headers[k] ||= v }
          response.headers['Content-Length'] = headers['Content-Length']
          response.no_cache.cache_private if opts[:no_cache]
        end

        def content_headers
          ct = Tzispa::Helpers::Services::ContentType.new response
          ct.file opts[:type], opts[:extension]
          last_modified opts[:last_modified] if opts[:last_modified]
        end
      end

    end
  end
end
