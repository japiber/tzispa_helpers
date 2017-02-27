# frozen_string_literal: true

require_relative 'html'

module Tzispa
  module Helpers
    module Pattern

      include Tzispa::Helpers::Html

      def pattern_select_hours(selected = nil)
        selected &&= selected.to_i
        proc do
          (0..23).map do |hour|
            loop_item(
              value: hour,
              text: hour.to_s.rjust(2, '0'),
              selected: html_selected(selected == hour)
            )
          end
        end
      end

      def pattern_select_minutes(selected = nil)
        selected &&= selected.to_i
        proc do
          (0..59).map do |minute|
            loop_item(
              value: minute,
              text: minute.to_s.rjust(2, '0'),
              selected: html_selected(selected == minute)
            )
          end
        end
      end

      def pattern_select_year(first, last, selected = nil)
        selected &&= selected.to_i
        proc do
          ryear = (first..last)
          enum_year = first > last ? ryear.first.downto(ryear.last) : ryear.first.to(ryear.last)
          enum_year.map do |year|
            loop_item(
              value: year,
              text:  year,
              selected: html_selected(selected == year)
            )
          end
        end
      end

    end
  end
end
