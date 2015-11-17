require 'mail'

module Tzispa
  module Helpers
    module Mail

      def send_smtp_mail(from:, to:, subject:, body:, config:, html: false)
        begin
          smtp_configuration config
          mail = ::Mail.new
          mail.from    = from
          mail.to      = to
          mail.subject = subject
          if html
            mail.html_part do
              content_type 'text/html; charset=UTF-8'
              body = body
            end
          else
            mail.body    = body
          end
          mail.deliver
        rescue
          nil
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
