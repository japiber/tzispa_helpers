module Tzispa
  module Helpers
    module Pattern

      def pattern_select_hours(selected=nil)
        selected = selected.to_i
        Enumerator.new { |litems|
          (0..23).each { |h|
            item = OpenStruct.new
            item.value = h
            item.text = h.to_s.rjust(2, '0')
            item.selected = html_selected selected == h
            litems << item
          }
        }
      end

      def pattern_select_minutes(selected=nil)
        selected = selected.to_i
        Enumerator.new { |litems|
          (0..59).each { |m|
            item = OpenStruct.new
            item.value = m
            item.text = m.to_s.rjust(2, '0')
            item.selected = html_selected selected == m
            litems << item
          }
        }
      end


    end
  end
end
