require 'tzispa/rig/template'


module Tzispa
  module Helpers
    module ErrorView

      def error_report(error=nil)
        text = String.new('<!DOCTYPE html>')
        text << '<html lang="es"><head>'
        text << '<meta charset="utf-8" />'
        text << '<style> html {background:#cccccc; font-family:Arial; font-size:15px; color:#555;} body {width:75%; max-width:1200px; margin:18px auto; background:#fff; border-radius:6px; padding:32px 24px;} ul{list-style:none; margin:0; padding:0;} li{font-style:italic; color:#666;} h1 {color:#2ECC71;} </style>'
        text << '</head><body>'
        text << "<h5>#{Tzispa::FRAMEWORK_NAME} #{Tzispa::VERSION}</h5>\n"
        if error
          text << "<h1>#{error.class.name}</h1><h3>#{error.message}</h1>\n"
          text << '<ol>' + error.backtrace.map { |trace| "<li>#{trace}</li>\n" }.join + '</ol>' if error.respond_to?(:backtrace) && error.backtrace
        else
          text << "<h1>Error 500</h1>\n"
          text << "Se ha producido un error inesperado al tramitar la petición"
        end
        text << '</body></html>'
      end

      def error_page(status, domain)
        begin
          error_file = "#{domain.path}/error/#{status}.htm"
          Tzispa::Rig::File.new(error_file).load!.content
        rescue
          text = String.new('<!DOCTYPE html>')
          text << '<html lang="es"><head>'
          text << '<meta charset="utf-8" />'
          text << '<style> html {background:#cccccc; font-family:Arial; font-size:15px; color:#555;} body {width:75%; max-width:1200px; margin:18px auto; background:#fff; border-radius:6px; padding:32px 24px;} #main {margin:auto; } h1 {color:#2ECC71; font-size:4em; text-align:center;} </style>'
          text << '</head><body>'
          text << '<div id="main">'
          text << "<h5>#{Tzispa::FRAMEWORK_NAME} #{Tzispa::VERSION}</h5>\n"
          text << "<h1>Error #{status}</h1>\n"
          text << '</div>'
          text << '</body></html>'
        end
      end


    end
  end
end
