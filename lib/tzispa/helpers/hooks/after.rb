# frozen_string_literal: true

module Tzispa
  module Helpers
    module Hooks
      module After

        def self.included(base)
          base.extend(ClassMethods)
        end

        def do_after
          self.class.after.each { |hook| send hook }
        end

        module ClassMethods
          def after(*args)
            (@after_chain ||= []).tap do |bef|
              args&.each do |s|
                s = s.to_sym
                bef << s unless bef.include?(s)
              end
            end
          end
        end
      end
    end
  end
end
