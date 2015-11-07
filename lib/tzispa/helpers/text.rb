require 'date'
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

      def join_to_nil(ary, separator)
        ary.join(separator) if ary and not ary.empty?
      end

      def str_to_bool(str, strue)
        str ? (str == strue) : false
      end

      def str_to_date(str, format='%d/%m/%Y')
        begin
          result = Date.strptime(str, format)
        rescue
          result = nil
        end
        result
      end

      def str_to_datetime(str, format='%d/%m/%Y %H:%M:%S')
        begin
          result = DateTime.strptime(str, format)
        rescue
          result = nil
        end
        result
      end


    end
  end
end
