# frozen_string_literal: true

module Tzispa
  module Helpers
    module Login

      def login_redirect
        context.redirect(context.layout_path(context.config.login_layout.to_sym), true, context.response) if login_redirect?
      end

      def login_redirect?
        !context.logged? && (context.layout != context.config.login_layout)
      end

      def unauthorized_but_logged
        context.not_authorized unless context.logged?
      end

    end
  end
end
