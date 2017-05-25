# frozen_string_literal: true

require 'tzispa/utils/string'
require 'json'
require_relative 'text'

module Tzispa
  module Helpers
    module MacroField

      include Tzispa::Helpers::Text
      using Tzispa::Utils::TzString

      def process_macros(source, fields, data_object: nil, json: nil)
        (data_object || {}).tap do |data|
          fields.each do |name|
            macro_field = name.split('@:')
            macro = macro_field.first.to_sym if macro_field.length == 2
            field = macro_field.length == 2 ? macro_field.last : macro_field.first
            build_field source, field, macro, data
          end
          json&.each do |key, value|
            data.send "#{key}=", build_json_field(source, value)
          end
        end
      end

      def build_field(source, field, macro, data)
        field.split(':').tap do |orig, dest|
          dest ||= orig
          value = if String == source[orig]
                    String.unescape_html(source[orig])
                  else
                    source[orig]
                  end
          value = macro ? send(macro, value) : value
          if data.is_a? ::Hash
            data[dest.to_sym] = value
          else
            data.send "#{dest}=".to_sym, value
          end
        end
      end

      def build_json_field(source, values)
        {}.tap do |data|
          values.each do |name|
            macro_field = name.split('@:')
            macro = macro_field.first.to_sym if macro_field.length == 2
            field = macro_field.length == 2 ? macro_field.last : macro_field.first
            build_field source, field, macro, data
          end
        end.to_json
      end

    end
  end
end
