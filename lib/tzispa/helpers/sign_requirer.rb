# frozen_string_literal: true

require_relative 'requirer'

module Tzispa
  module Helpers
    module SignRequirer

      def self.included(base)
        base.include Tzispa::Helpers::Requirer
        base.extend(ClassMethods)
      end

      def sign_required?
        self.class.sign_required?
      end

      def sign_valid?
        self.class.sign_valid? self
      end

      module ClassMethods
        def sign_required!(&block)
          required(:router_params, :sign, &block)
        end

        def sign_required?
          required? :router_params, :sign
        end

        def sign_valid?(obj)
          required_valid? :router_params, :sign, obj
        end
      end

    end
  end
end
