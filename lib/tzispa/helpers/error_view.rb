# frozen_string_literal: true

require 'tzispa/rig/template'
require 'tzispa/version'
require 'tzispa/helpers/services/error_view'

module Tzispa
  module Helpers
    module ErrorView

      ERROR_HEADER = <<-ERRORHEADER
      <head>
      <meta charset="utf-8" />
      <style> html {background:#cccccc; font-family:Arial; font-size:15px; color:#555;} body {width:75%; max-width:1200px; margin:18px auto; background:#fff; border-radius:6px; padding:32px 24px;} #main {margin:auto; } ul{list-style:none; margin:0; padding:0;} li{font-style:italic; color:#666;} h1 {color:#2ECC71;} </style>
      </head>
      ERRORHEADER

      ERROR_PLATFORM_VERSIONS = <<-ERRORPVERSION
      <h6>#{Tzispa::FRAMEWORK_NAME} #{Tzispa::VERSION}</h6>
      ERRORPVERSION

      def debug_info(ex = nil, status: 500)
        String.new.tap do |text|
          text << '<!DOCTYPE html><html lang="es">'
          text << ERROR_HEADER << '<body>'
          text << ERROR_PLATFORM_VERSIONS
          text << if ex
                    srx = Tzispa::Helpers::Services::ErrorView ex
                    "<h1>#{srx.error_header}\n #{srx.error_backtrace_list}"
                  else
                    "<h1>Error #{status}</h1>\nSe ha producido un error indeterminado"
                  end
          text << '</body></html>'
        end
      end

      def error_page(domain, status: 500)
        error_file = "#{domain.path}/error/#{status}.htm"
        if (ef = Tzispa::Rig::File.new(error_file)) && ef.exist?
          ef.load!.content
        else
          error_default
        end
      end

      def error_log(ex)
        Tzispa::Helpers::Services::ErrorView(ex).error_backtrace_log
      end

      def error_default
        String.new.tap do |text|
          text << '<!DOCTYPE html><html lang="es">'
          text << ERROR_HEADER << '<body>'
          text << '</head><body>'
          text << '<div id="main">'
          text << ERROR_PLATFORM_VERSIONS
          text << "<h1>Error #{status}</h1>\n"
          text << '</div>'
          text << '</body></html>'
        end
      end

    end
  end
end
