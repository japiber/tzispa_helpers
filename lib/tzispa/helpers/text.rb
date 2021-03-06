# frozen_string_literal: true

require 'date'
require 'bigdecimal'
require 'i18n'
require 'unicode_utils'
require 'cgi/util'

module Tzispa
  module Helpers
    module Text

      def remove_words(sentence, removable)
        sentence.split.delete_if { |x| removable.include? UnicodeUtils.downcase(x) }.join(' ')
      end

      def remove_phrases(text, removable)
        removable.each { |phrase| text.slice! phrase }
        text
      end

      def remove_parenthesized_text(text)
        text.gsub(/\([^\)]*\)/, '')
      end

      def synonymize(sentence, synonyms)
        sentence.gsub(/[[:alnum:]]+/) do |word|
          dwword = UnicodeUtils.downcase word
          synonyms.key?(dwword) ? synonyms[dwword] : word
        end
      end

      def strip_to_nil(str, transform = nil)
        sstr = str.strip if str && !str.strip.empty?
        case transform
        when :upcase then
          UnicodeUtils.upcase(sstr)
        when :downcase then
          UnicodeUtils.downcase(sstr)
        when :titlecase then
          UnicodeUtils.titlecase(sstr)
        else
          sstr
        end
      end

      def html_unscape(str)
        CGI.unescapeHTML(str.strip) if str && !str.strip.empty?
      end

      def split_to_array(str, separator = ';')
        str&.split(separator)
      end

      def join_to_nil(ary, separator)
        ary.join(separator) if ary && !ary.empty?
      end

      def str_to_bool(str, strue = nil)
        strue ? (strue == str) : (str == 'yes' || str == 'true')
      end

      def str_to_integer(str)
        return unless (sstr = strip_to_nil(str))
        Integer sstr
      end

      def str_to_date(str, format = nil)
        str = strip_to_nil str
        Date.strptime(str, format || I18n.t('date.formats.default')) if str
      end

      def str_to_datetime(str, format = nil)
        str = strip_to_nil str
        DateTime.strptime(str, format || I18n.t('datetime.formats.default'))
      end

      def str_time_ellapsed(t_start, t_end = nil)
        elapsed = (t_end || Time.now) - t_start
        seconds = elapsed % 60
        minutes = (elapsed / 60) % 60
        hours = elapsed / (60 * 60)
        format('%02d:%02d:%02d', hours, minutes, seconds)
      end

      def str_to_amount(str, options = {})
        return unless !str || str.strip.empty?
        separator = options.fetch(:separator, I18n.t('number.currency.format.separator'))
        precision = options.fetch(:precision, I18n.t('number.currency.format.precision'))
        str = str.gsub(Regexp.new("[^\\d\\#{separator}\\-]"), '')
        str = str.gsub(separator, '.') if separator != '.'
        BigDecimal.new(str).round(precision).to_s('F')
      end

      def amount(number, options = {})
        if number.nil? && options[:nil_as_dash] != false
          '–'
        elsif number.zero? && options[:zero_as_dash]
          '–'
        else
          precision = options[:precision]
          if precision
            options[:minimum_precision] = precision unless options[:minimum_precision]
            options[:maximum_precision] = precision unless options[:maximum_precision]
          end

          number = number.round if options[:round]
          separator = options.fetch(:separator, I18n.t('number.currency.format.separator'))
          delimiter = options.fetch(:delimiter, I18n.t('number.currency.format.delimiter')).to_s
          minimum_precision = options[:minimum_precision] || 0
          str = if number.is_a?(BigDecimal)
                  number.to_s('F').sub(/\.0+\z/, '')
                else
                  number.to_s.sub(/\.0+\z/, '')
                end
          smatch = str.match(/\A(\-?)(\d+)(?:\.(\d+))?\z/)
          raise "Could not parse number: #{number}" unless smatch
          sign = smatch[1]
          integer = smatch[2]
          fraction = (smatch[3] || '')

          if options[:maximum_precision]
            fraction = fraction[0, options[:maximum_precision]] if options[:maximum_precision]
          end

          if fraction.positive? && minimum_precision.positive?
            fraction = "#{fraction}#{'0' * [0, minimum_precision - fraction.length].max}"
          elsif minimum_precision.zero? && !fraction.empty? && fraction.to_i.zero?
            fraction = ''
          end

          # add a delimiter to every thousands place in the number
          integer_size = integer.size
          (1..((integer_size - 1) / 3)).each { |x| integer[integer_size - x * 3, 0] = delimiter }
          str = integer.chomp(delimiter)

          # add fraction
          str << "#{separator}#{fraction}" unless fraction.empty?

          # restore sign
          str = "#{sign}#{str}"
          # add unit if given
          if options[:unit]
            unless options[:unit_separator] == false
              str << options.fetch(:unit_separator, ' ')
            end
            str << options[:unit]
          end
          str
        end
      end

      def money_amount(number, options = {})
        amount(number, options.merge(unit: I18n.t('number.currency.format.unit'),
                                     nil_as_dash: false,
                                     precision: I18n.t('number.currency.format.precision'),
                                     minimum_precision: 0))
      end

      def price_amount(number, options = {})
        amount(number, options.merge(nil_as_dash: false,
                                     precision: I18n.t('number.currency.format.precision'),
                                     minimum_precision: 0))
      end

      def starinizer(rating, star_value, max_stars)
        {}.tap do |stars|
          stars[:full] = rating / star_value
          stars[:half] = rating % star_value
          stars[:o] = max_stars - stars[:full] - stars[:half]
        end
      end

    end
  end
end
