# frozen_string_literal: true

require 'digest'

module Tzispa
  module Helpers
    module Security

      def secret(length)
        alfanb = (['!', '"', '·', '$', '%', '&', '/', '(', ')', '=',
                   '?', '+', '@', '#', ',', '.', '-', ';', ':', '_',
                   '[', ']', '>', '<', '*'] <<
                  [('a'..'z'), ('0'..'9'), ('A'..'Z')].map(&:to_a)).flatten
        (0...length).map { alfanb[rand(alfanb.length)] }.join
      end

      def uuid
        format('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
               rand(0..0xffff),
               rand(0..0xffff),
               rand(0..0xffff),
               rand(0..0x0fff) | 0x4000,
               rand(0..0x3fff) | 0x8000,
               rand(0..0xffff),
               rand(0..0xffff),
               rand(0..0xffff))
      end

      def sign_array(astr, salt = nil)
        sign = String.new
        i = 0
        astr.each do |s|
          i += 1
          sign << "#{'_' * i}#{s}"
        end
        sign << "**#{salt}"
        Digest::SHA1.hexdigest sign
      end

      def hash_password(password, salt)
        Digest::MD5.hexdigest "#{password}::#{salt}"
      end

      def hash_password?(hashed, pwd, salt)
        hashed == hash_password(pwd, salt)
      end

    end
  end
end
