require 'digest'


module Tzispa
  module Helpers
    module Security


      def secret(length)
        alfanb = ['!', '$', '%', '&', '@', '#', '=', '_' '+', '-', '*', '/', '?', ':', ';', '.', ',',
                   ('a'..'z'), ('0'..'9'), ('A'..'Z')].map { |i| i.to_a }.flatten
        (0...length-1).map { alfanb[rand(alfanb.length)] }.join
      end

      def uuid
        sprintf('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
          # 32 bits for "time_low"
          rand(0..0xffff), rand(0..0xffff),

          # 16 bits for "time_mid"
          rand(0..0xffff),

          # 16 bits for "time_hi_and_version",
          #3 four most significant bits holds version number 4
          rand(0..0x0fff) | 0x4000,

          # 16 bits, 8 bits for "clk_seq_hi_res",
          # 8 bits for "clk_seq_low",
          # two most significant bits holds zero and one for variant DCE1.1
          rand(0..0x3fff) | 0x8000,

          # 48 bits for "node"
          rand(0..0xffff), rand(0..0xffff), rand(0..0xffff)
        )
      end

      def sign_array(astr, salt=nil)
        sign, i = "", 0
        astr.each { |s|
          i = i + 1
          sign << "#{"_"*i}#{s}"
        }
        sign << "**#{salt}"
        Digest::SHA1.hexdigest sign
      end

      def hash_password(password, salt)
        Digest::MD5::hexdigest "#{password}::#{salt}"
      end

      def hash_password?(hashed, pwd, salt)
        hashed == hash_password(pwd, salt)
      end


      class Identity

        attr_reader :id, :token

        def initialize(id, secret)
          @id = id
          @token = generate_token id, secret
        end

        def valid?(secret)
          @token == Identity.generate_token(@id, secret)
        end

        private

        def self.generate_token(value, salt)
          Digest::SHA1.hexdigest "___#{value}_#{salt}__token__"
        end

      end


    end
  end
end
