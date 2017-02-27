# frozen_string_literal: true

module Tzispa
  module Helpers
    module DateTime

      def date_months_diff(date1, date2)
        (date2.year - date1.year) * 12 +
          date2.month - date1.month - (date2.day >= date1.day ? 0 : 1)
      end

      def date_days_diff(date1, date2)
        date2.mjd - date1.mjd
      end

    end
  end
end
