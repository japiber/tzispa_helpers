require 'net/http'

module Tzispa
  module Helpers
    module Recaptcha

      RECAPTCHA_VERIFY_URL      = 'https://www.google.com/recaptcha/api/siteverify'
      RECAPTCHA_RESPONSE_FIELD  = 'g-recaptcha-response'

      def verify(secret, response, ip)
        params = {
          'secret':   secret,
          'response': response,
          'remoteip': ip
        }

        uri  = URI.parse(RECAPTCHA_VERIFY_URL)
        http = Net::HTTP.start(uri.host, uri.port)

        request           = Net::HTTP::Post.new(uri.path)
        request.form_data = params
        response          = http.request(request)

        JSON.parse response.body
      end


    end
  end
end
