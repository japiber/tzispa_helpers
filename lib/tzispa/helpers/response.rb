# frozen_string_literal: true

require 'uri'
require_relative 'mime'

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
          def block.each; yield(call) end
          response.body = block
        elsif value
          headers.delete 'Content-Length' unless request.head? || value.is_a?(Rack::File) || value.is_a?(Stream)
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
        if env['HTTP_VERSION'] == 'HTTP/1.1' and env["REQUEST_METHOD"] != 'GET'
          status 303
        else
          status 302
        end

        # According to RFC 2616 section 14.30, "the field value consists of a
        # single absolute URI"
        response['Location'] = uri(uri.to_s, absolute)
        halt(*args)
      end

      # Generates the absolute URI for a given path in the app.
      # Takes Rack routers and reverse proxies into account.
      def uri(addr = nil, absolute = true)
        return addr if addr =~ /\A[A-z][A-z0-9\+\.\-]*:/
        uri = [host = String.new]
        if absolute
          host << "http#{'s' if request.secure?}://"
          if request.forwarded? or request.port != (request.secure? ? 443 : 80)
            host << request.host_with_port
          else
            host << request.host
          end
        end
        uri << (addr ? addr : request.path_info).to_s
        File.join uri
      end

      # Halt processing and return the error status provided.
      def error(code, body = nil)
        code, body    = 500, code.to_str if code.respond_to? :to_str
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

      # Set multiple response headers with Hash.
      def headers(hash = nil)
        response.headers.merge! hash if hash
        response.headers
      end

      # Set the Content-Type of the response body given a media type or file
      # extension.
      def content_type(type = nil, params = {})
        return response['Content-Type'] unless type
        default = params.delete :default
        mime_type = mime_type(type) || default
        fail "Unknown media type: %p" % type if mime_type.nil?
        mime_type = mime_type.dup
        unless params.include? :charset
          params[:charset] = params.delete('charset') || config.default_encoding
        end
        params.delete :charset if mime_type.include? 'charset'
        unless params.empty?
          mime_type << (mime_type.include?(';') ? ', ' : ';')
          mime_type << params.map do |key, val|
            val = val.inspect if val =~ /[";,]/
            "#{key}=#{val}"
          end.join(', ')
        end
        response['Content-Type'] = mime_type
      end

      def attachment!(filename = nil, disposition = 'attachment')
        content_disposition = disposition.to_s
        content_disposition += "; filename=\"#{filename}\"; filename*=UTF-8''#{URI.escape(filename)}" if !filename.nil?
        response['Content-Disposition'] = content_disposition
      end

      # Use the contents of the file at +path+ as the response body.
      def send_file(path, opts = {})
        begin
          if opts[:type] or not response['Content-Type']
            content_type opts[:type] || opts[:extension], :default => 'application/octet-stream'
          end

          disposition = opts[:disposition]
          filename    = opts[:filename]
          disposition = 'attachment' if disposition.nil? and filename
          filename    = path         if filename.nil?

          attachment! filename, disposition
          last_modified opts[:last_modified] if opts[:last_modified]

          file      = Rack::File.new nil
          file.path = path
          result    = file.serving context.env
          result[1].each { |k,v| response.headers[k] ||= v }
          response.headers['Content-Length'] = result[1]['Content-Length']
          #opts[:status] &&= Integer(opts[:status])
          #halt opts[:status] || result[0], result[2]
          response.status = result[0]
          response.body = result[2]
        rescue
          not_found 'Fichero no encontrado'
        end
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


      class NotFound < NameError #:nodoc:
        def http_status; 404 end
      end


    end
  end
end
