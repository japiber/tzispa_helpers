# frozen_string_literal: true

require 'securerandom'
require_relative 'session_flash_bag'

module Tzispa
  module Helpers
    module Session

      SESSION_LAST_ACCESS   = :__last_access
      SESSION_ID            = :__session_id
      GLOBAL_MESSAGE_FLASH  = :__global_message_flash

      def init_session
        generate_session_id if config.sessions&.enabled && !session?
      end

      def set_last_access
        session[SESSION_LAST_ACCESS] = Time.now.utc.iso8601
      end

      def last_access
        session[SESSION_LAST_ACCESS]
      end

      def flash
        @flash ||= SessionFlashBag.new(session, GLOBAL_MESSAGE_FLASH)
      end

      def session?
        !session[SESSION_ID].nil? && (session[SESSION_ID] == session.id)
      end

      private

      def generate_session_id
        SecureRandom.uuid.tap do |uuid|
          session.id = uuid
          session[SESSION_ID] = uuid
        end
      end

    end
  end
end
