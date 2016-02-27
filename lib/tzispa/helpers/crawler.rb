# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'htmlentities'
require 'reverse_markdown'
require 'unicode_utils'
require 'redcarpet'

module Tzispa
  module Helpers
    module Crawler


      def crawler_save_file(url, dest_file)
        File.open("#{dest_file}", 'wb') do |fo|
             fo.write open(url).read
        end
      end

      def crawler_to_markdown(source)
        begin
          source = source.read if source.respond_to? :read
          htmee = HTMLEntities.new
          ReverseMarkdown.convert(htmee.decode(source).strip, unknown_tags: :bypass)
        rescue Encoding::UndefinedConversionError
        end
      end

      def crawler_table_to_dl(source, table_path, columns=2, excluded_terms=[])
        String.new.tap { |content|
          dt, dd = Array.new, Array.new
          htmee = HTMLEntities.new
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
          Nokogiri::HTML(source)&.xpath(table_path).collect { |row|
            dterm = htmee.decode(row.at_xpath('td[1]')&.content).strip
            if dterm.length > 0 && !excluded_terms.include?(UnicodeUtils.downcase dterm)
              dt << dterm
              dd << (2..columns).map { |i|
                  ReverseMarkdown.convert(htmee.decode(row.at_xpath("td[#{i}]")&.children&.to_s || row.at_xpath("td[#{i}]")&.to_s).strip, unknown_tags: :bypass)
              }.join('\n')
            end
          }
          if dt.length > 0
            content << '<dl>'
            dt.zip(dd).sort.each do |idt,idd|
               if idt.length > 0 && !excluded_terms.include?(UnicodeUtils.downcase idt)
                 content << "<dt>#{idt}</dt>"
                 content << "<dd>#{markdown.render idd}</dd>"
               end
            end
            content << "</dl>"
          end
        }
      end


    end
  end
end
