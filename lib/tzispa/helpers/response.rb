# frozen_string_literal: true

require 'uri'
require_relative 'mime'
require_relative 'services/send_file'
require_relative 'services/content_type'

module Tzispa
  module Helpers
    module Response

      def self.included(base)
        base.class_eval do
          include Tzispa::Helpers::Mime
        end
      end

      # Set or retrieve the response status code.
      def status(value = nil)
        response.status = value if value
        response.status
      end

      # Set or retrieve the response body. When a block is given,
      # evaluation is deferred until the body is read with #each.
      def body(value = nil, &block)
        if block_given?
          def block.each
            yield(call)
          end
          response.body = block
        elsif value
          headers.delete 'Content-Length' unless request.head? ||
                                                 value.is_a?(Rack::File) ||
                                                 value.is_a?(Stream)
          response.body = value
        else
          response.body
        end
      end

      # Exit the current block, halts any further processing
      # of the request, and returns the specified response.
      def halt(*response)
        response = response.first if response.length == 1
        throw :halt, response
      end

      # Halt processing and redirect to the URI provided.
      def redirect(uri, absolute, *args)
        status(request.allowed_http_version? && request.get? ? 303 : 302)
        response['Location'] = uri(uri.to_s, absolute)
        halt(*args)
      end

      # Halt processing and permanet_redirect redirect to the URI provided.
      def permanent_redirect(uri, absolute, *args)
        status 301
        response['Location'] = uri(uri.to_s, absolute)
        halt(*args)
      end

      # Generates the absolute URI for a given path in the app.
      # Takes Rack routers and reverse proxies into account.
      def uri(addr = nil, absolute = true)
        return addr if addr.match?(/\A[A-z][A-z0-9\+\.\-]*:/)
        uri = [host = String.new]
        host << uri_host if absolute
        uri << (addr ? addr : request.path_info).to_s
        File.join uri
      end

      def uri_host
        String.new.tap do |host|
          host << "http#{'s' if request.secure?}://"
          host << (uri_port? ? request.host_with_port : request.host)
        end
      end

      def uri_port?
        request.forwarded? || request.port != (request.secure? ? 443 : 80)
      end

      # Halt processing and return the error status provided.
      def error(code = 500, body = nil)
        body = code.to_str if code.respond_to? :to_str
        response.body = body unless body.nil?
        halt code
      end

      # Halt processing and return a 404 Not Found
      def not_found(body = nil)
        error 404, body
      end

      # Halt processing and return a 401 Unauthorized
      def unauthorized(body = nil)
        error 401, body
      end
      alias not_authorized unauthorized

      # Set multiple response headers with Hash.
      def headers(hash = nil)
        response.headers.merge! hash if hash
        response.headers
      end

      # Set the Content-Type of the response body given a media type or file
      # extension.
      def content_type(type = nil, params = {})
        return if response.drop_content_info?
        ct = Tzispa::Helpers::Services::ContentType.new(response,
                                                        config.default_encoding)
        ct.header(type, params)
      end

      def send_file(path, opts = {})
        not_found unless ::File.exist? path
        file = Rack::File.new(Dir.pwd)
        fss = Tzispa::Helpers::Services::SendFile.new response, path, opts
        fss.send file.serving(request, path)
      end

      # Sugar for redirect (example:  redirect back)
      def back
        request.referer
      end

      # whether or not the status is set to 1xx
      def informational?
        response.status.between? 100, 199
      end

      # whether or not the status is set to 2xx
      def success?
        response.status.between? 200, 299
      end

      # whether or not the status is set to 3xx
      def redirect?
        response.status.between? 300, 399
      end

      # whether or not the status is set to 4xx
      def client_error?
        response.status.between? 400, 499
      end

      # whether or not the status is set to 5xx
      def server_error?
        response.status.between? 500, 599
      end

      # whether or not the status is set to 404
      def not_found?
        response.status == 404
      end

      def error_500(str)
        500.tap { |_code| response.body = str if str }
      end

      class NotFound < NameError #:nodoc:
        def http_status
          404
        end
      end

    end
  end
end
