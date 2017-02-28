# frozen_string_literal: true

require 'forwardable'
require 'json'

module Tzispa
  module Helpers
    module Session

      class SessionFlashBag
        extend Forwardable

        def_delegators :@bag, :count, :length, :size, :each

        SESSION_FLASH_BAG = :__flash_bag

        def initialize(session, key)
          @session = session
          @session_key = "#{SESSION_FLASH_BAG}_#{key}".to_sym
          load!
        end

        def <<(value)
          return unless value
          bag << value
          store
        end

        def pop
          value = bag.pop
          store
          value
        end

        def pop_all
          empty!
          bag
        end

        def push(value)
          bag.push value
          store
        end

        private

        attr_reader :bag, :session, :session_key

        def load!
          @bag = session[session_key] ? JSON.parse(session[session_key]) : []
        end

        def store
          session[session_key] = bag.to_json
        end

        def empty!
          session[session_key] = []
        end
      end

    end
  end
end
