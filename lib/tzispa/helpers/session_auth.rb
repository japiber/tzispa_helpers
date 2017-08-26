# frozen_string_literal: true

require 'digest'

module Tzispa
  module Helpers
    module SessionAuth

      SESSION_AUTH_USER = :__auth__user

      class Authentication
        attr_reader :id

        def initialize(id, secret)
          @id = id
          @token = generate_token secret
        end

        def valid?(secret)
          @token == generate_token(secret)
        end

        private

        attr_reader :token

        def generate_token(secret)
          Digest::MD5.hexdigest "___#{id}__authtoken__#{secret}_"
        end
      end

      def session_auth?
        return unless context.session?
        ident = context.session[SESSION_AUTH_USER]
        ident&.valid?(context.session.id)
      end

      def session_auth
        ident = context.session[SESSION_AUTH_USER]
        ident.id if session_auth?
      end
      alias session_login session_auth

      def session_login(user)
        context.session[SESSION_AUTH_USER] = Authentication.new(user, context.session.id)
      end

      def session_logout
        context.session.delete(SESSION_AUTH_USER)
      end

      def login_redirect
        login_layout = context.layout_path(context.config.login_layout.to_sym)
        context.redirect(login_layout, true, context.response) if login_redirect?
      end

      def login_redirect?
        !session_auth? && (context.layout != context.config.login_layout)
      end

      def unauthorized_but_auth
        context.not_authorized unless session_auth?
      end

    end
  end
end
