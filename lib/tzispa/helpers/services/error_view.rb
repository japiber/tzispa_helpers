# frozen_string_literal: true

module Tzispa
  module Helpers
    module Services

      class ErrorView
        attr_reader :exception

        def initialize(exception)
          @exception = exception
        end

        def error_header
          "<h1>#{exception.class.name}</h1><h3>#{exception.message}</h3>"
        end

        def error_backtrace_list
          return unless exception.respond_to?(:backtrace) && exception.backtrace
          String.new.tap do |str|
            str << '<ol>'
            str << exception.backtrace.map { |trace| "<li>#{trace}</li>\n" }.join
            str << '</ol>'
          end
        end

        def error_backtrace_log
          return unless exception.respond_to?(:backtrace) && exception.backtrace
          String.new.tap do |str|
            str << "#{exception.class.name}: #{exception}:\n"
            str << exception.backtrace.join("\n")
          end
        end
      end

    end
  end
end
