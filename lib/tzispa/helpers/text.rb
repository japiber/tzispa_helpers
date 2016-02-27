# frozen_string_literal: true

require 'date'
require 'bigdecimal'
require 'i18n'
require "unicode_utils"

module Tzispa
  module Helpers
    module Text

      def remove_words(sentence, removable)
        sentence.split.delete_if{|x| removable.include?(UnicodeUtils.downcase x)}.join(' ')
      end

      def remove_phrases(text, removable)
        removable.each { |phrase|
          text.slice! phrase
        }
        text
      end

      def remove_parenthesized_text(text)
        text.gsub(/\([^\)]*\)/, '')
      end

      def synonymize(sentence, synonyms)
        sentence.gsub(/[[:alnum:]]+/) {|word|
          dwword = UnicodeUtils.downcase word
          synonyms.has_key?(dwword) ? synonyms[dwword] : word
        }
      end

      def strip_to_nil(str, transform = nil)
        sstr = str.strip if str and not str.strip.empty?
        case transform
          when :upcase then
             UnicodeUtils.upcase(sstr)
          when :downcase then
             UnicodeUtils.downcase(sstr)
          when :titlecase then
             UnicodeUtils.titlecase(sstr)
          else sstr
        end
      end

      def split_to_array(str, separator=';')
        str.split(separator) if str
      end

      def join_to_nil(ary, separator)
        ary.join(separator) if ary and not ary.empty?
      end

      def str_to_bool(str, strue=nil)
        strue ? (strue == str) : (str == 'yes' || str == 'true')
      end

      def str_to_date(str, format=nil)
        begin
          Date.strptime(str, format || I18n.t('date.formats.default')) if str
        rescue
          nil
        end
      end

      def str_to_datetime(str, format=nil)
        begin
          result = DateTime.strptime(str, format || I18n.t('time.formats.default'))
        rescue
          result = nil
        end
        result
      end

      def amount(number, options = {})
        if number.nil? && options[:nil_as_dash] != false
          '–'
        elsif number.zero? && options[:zero_as_dash]
          '–'
        else
          precision = options[:precision]
          if precision
            options[:minimum_precision] = precision
            options[:maximum_precision] = precision
          end

          number = number.round if options[:round]
          separator = options.fetch(:separator, I18n.t('number.currency.format.separator'))
          delimiter = options.fetch(:delimiter, I18n.t('number.currency.format.delimiter')).to_s
          minimum_precision = options[:minimum_precision] || 0
          str = number.is_a?(BigDecimal) ? number.to_s('F').sub(/\.0+\z/, "") : number.to_s.sub(/\.0+\z/, "")
          str =~ /\A(\-?)(\d+)(?:\.(\d+))?\z/ or raise "Could not parse number: #{number}"
          sign = $1
          integer = $2
          fraction = ($3 || '')

          if options[:maximum_precision]
            fraction = fraction[0, options[:maximum_precision]] if options[:maximum_precision]
          end

          if minimum_precision > 0
            if fraction.length > 0 || minimum_precision > 0
              fraction = "#{fraction}#{'0' * [0, minimum_precision - fraction.length].max}"
            end
          end

          # the following two lines appear to be the most performant way to add a delimiter to every thousands place in the number
          integer_size = integer.size
          (1..((integer_size-1) / 3)).each {|x| integer[integer_size-x*3,0] = delimiter}
          str = integer.chomp(delimiter)

          # add fraction
          str << "#{separator}#{fraction}" if fraction.length > 0

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
        amount(number, options.merge(:unit => I18n.t('number.currency.format.unit'), :nil_as_dash => true, :precision => I18n.t('number.currency.format.precision')))
      end

      def price_amount(number, options = {})
        amount(number, options.merge(:nil_as_dash => true, :precision => I18n.t('number.currency.format.precision')))
      end


    end
  end
end
