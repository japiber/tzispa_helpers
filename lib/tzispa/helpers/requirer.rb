module Tzispa
  module Helpers
    module Requirer

      def self.included(base)
        base.extend(ClassMethods)
      end

      def required?(target, value)
        self.class.required? target. value
      end

      def required_valid?(target, value)
        self.class.required_valid? target, value, self
      end

      module ClassMethods

        def required(target, value, &block)
          @required ||= Hash.new
          (@required[target] ||= Hash.new).tap { |reqt|
            reqt[value] = block || true
          }
        end

        def required?(target, value)
          @required&.fetch(target, nil)&.fetch(value, nil)
        end

        def required_valid?(target, value, obj)
          if (rq = required?(target, value)) && rq.respond_to?(:call)
            obj.instance_eval(&rq)
          else
            rq
          end
        end

      end

    end
  end
end
