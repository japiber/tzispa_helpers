# frozen_string_literal: true

require 'rack/mime'

module Tzispa
  module Helpers
    module Mime

      def mime_type(type, value = nil)
        return type      if type.nil?
        return type.to_s if type.to_s.include?('/')
        type = ".#{type}" unless type.to_s[0] == '.'
        return Rack::Mime.mime_type(type, nil) unless value
        Rack::Mime::MIME_TYPES[type] = value
      end

      def mime_extension(type)
        Rack::Mime::MIME_TYPES.invert[type]
      end

    end
  end
end
