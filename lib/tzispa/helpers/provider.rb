module Tzispa
  module Helpers
    module Provider

      def self.included(base)
        base.extend(ClassMethods)
      end

      def provides?(verb)
        self.class.provides? verb
      end

      module ClassMethods

        def provides(*args)
          (@provides ||= Hash.new).tap { |prv|
            args&.each { |s|
              prv[s.to_sym] = s
            }
          }
        end

        def provides?(verb)
          value = verb.to_sym
          provides.include?(value) && public_method_defined?(provides[value])
        end

        def provides_map(source, dest)
          provides[source] = dest
        end

      end


    end
  end
end
