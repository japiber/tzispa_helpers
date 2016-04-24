module Tzispa
  module Helpers
    module HashTrans

      def hash_fussion!(hash, fussion_keys={})
        hash.keys.each { |key|
          if fussion_keys.has_key?(key)
            hash[fussion_keys[key]] ?
              hash[fussion_keys[key]] += hash[key] :
              hash[fussion_keys[key]] = hash[key]
            hash.delete(key)
          end
        } unless fussion_keys.empty?
      end

    end
  end
end
