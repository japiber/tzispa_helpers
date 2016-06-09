# frozen_string_literal: true

require 'mail'

module Tzispa
  module Helpers
    module Mail

      def send_smtp_mail(from:, to:, subject:, body:, config:, cc: nil, html: false, debug: false, charset: 'UTF-8')
        begin
          smtp_configuration config
          mail = ::Mail.new
          mail.from = from
          if !to.empty?
            to_addrs = to.split(';')
            mail.to = to_addrs.pop
            to_addrs.each { |email|
              mail.to << email
            }
            if cc
              cc_addrs = cc.split(';')
              mail.cc = cc_addrs.pop
              cc_addrs.each { |email|
                mail.cc << email
              }
            end
            mail.subject = subject
            if html
              mail.html_part do
                content_type "text/html; charset=#{charset}"
                body = body
              end
            else
              mail.body = body
            end
            mail.charset = charset
            mail.deliver
          else
            nil
          end
        rescue
          raise if debug
        end
      end

      private

      def smtp_configuration(config)
        if config.smtp_auth
          ::Mail.defaults do
            delivery_method :smtp, address: config.host, domain: config.domain,
                            port: config.port, authentication: config.authentication,
                            openssl_verify_mode: config.openssl_verify, enable_starttls_auto: config.starttls_auto,
                            user_name: config.user_name, password: config.password
          end
        else
          ::Mail.defaults do
            delivery_method :smtp, address: config.host, domain: config.domain,
                            port: config.port, openssl_verify_mode: config.openssl_verify,
                            enable_starttls_auto: config.starttls_auto
          end
        end
      end



    end
  end
end
