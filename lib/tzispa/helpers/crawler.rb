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

      def crawler_table_to_dl(noko, table_path, columns, excluded_terms: [], fussion_terms:{})
        String.new.tap { |content|
          markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
          sections = crawler_table(noko, table_path, columns)
          sections.keys.each { |key|
            if fussion_terms.has_key?(key)
              sections[fussion_terms[key]] ?
                sections[fussion_terms[key]] += sections[key] :
                sections[fussion_terms[key]] = sections[key]
              sections.delete(key)
            end
          } unless fussion_terms.empty?
          unless sections.empty?
            content << '<dl>'
            sections.sort.each { |key, value|
              unless key.empty? || value.empty? || excluded_terms.include?(UnicodeUtils.downcase key)
                content << "<dt>#{key}</dt>"
                if value.is_a?(Array) && value.count > 1
                  content << '<ul>' << value.map { |item| "<li>#{markdown.render item}</li>"}.join("\n") << '</ul>'
                elsif value.is_a?(Array) && value.count == 1
                  content << "<dd>#{markdown.render value.first}</dd>"
                else
                  content << "<dd>#{markdown.render value}</dd>"
                end
              end
            }
            content << "</dl>"
          end
        }
      end

      def crawler_table(noko, table_path, columns)
        Hash.new.tap { |sections|
          htmee = HTMLEntities.new
          noko = noko.xpath(table_path)
          colspans = "td[@colspan=\"#{columns}\"]"
          if noko.xpath(colspans).count == 0
            noko.collect { |row|
              dterm = htmee.decode(row.at_xpath('td[1]')&.content).gsub(/\n|\r|\t/,' ').strip
              unless dterm.empty?
                sections[dterm] ||= Array.new
                sections[dterm] << (2..columns).map { |i|
                    ReverseMarkdown.convert(htmee.decode(row.at_xpath("td[#{i}]")&.children&.to_s || row.at_xpath("td[#{i}]")&.to_s).strip, unknown_tags: :bypass).gsub(/\r|\t/,' ').strip
                }.join('\n')
              end
            }
          else
            current_section = nil
            noko.collect { |row|
               unless row.xpath(colspans)&.text.strip.empty?
                 current_section = row.xpath("td[@colspan=\"#{columns}\"]").text.gsub(/\n|\r|\t/,' ').strip
                 sections[current_section] ||= Array.new
               else
                 if current_section
                   sections[current_section] << (1..columns).map { |i|
                       ReverseMarkdown.convert(htmee.decode(row.at_xpath("td[#{i}]")&.children&.to_s.strip || row.at_xpath("td[#{i}]")&.to_s.strip), unknown_tags: :bypass).gsub(/\r|\t/,' ').strip
                   }.join(': ')
                 end
               end
             }
          end
        }
      end


    end
  end
end
