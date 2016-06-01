# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'htmlentities'
require 'reverse_markdown'
require 'unicode_utils'
require 'redcarpet'
require 'tzispa/helpers/hash_trans'

module Tzispa
  module Helpers
    module Crawler

      include Tzispa::Helpers::HashTrans

      class CrawlerError < StandardError; end


      def crawler_save_file(url, dest_file, accept_schemes = ['http', 'https', 'ftp'])
        begin
          uri = URI(url)
          raise ArgumentError.new "Inavlid url: #{url}" unless accept_schemes.include?(uri.scheme) && uri.host
          File.delete(dest_file) if File.exist?(dest_file)
          File.open("#{dest_file}", 'wb') do |fo|
            fo.write open(url).read
          end
        rescue => ex
          raise CrawlerError.new "Error in crawler_save_file '#{url}': #{ex.message}"
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
          hash_fussion! sections, fussion_terms
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
          htmee = HTMLEntities.new(:expanded)
          noko = noko.xpath(table_path)
          colspans = "td[@colspan=\"#{columns}\"]"
          if noko.xpath(colspans).count == 0
            noko.collect { |row|
              dterm = htmee.decode(row.at_xpath('td[1]')&.content).gsub(/\n|\r|\t/,' ').strip
              unless dterm.empty?
                sections[dterm] ||= Array.new
                sections[dterm] << (2..columns).map { |i|
                    ReverseMarkdown.convert(
                      htmee.decode(row.at_xpath("td[#{i}]")&.children&.to_s || row.at_xpath("td[#{i}]")&.to_s).strip, unknown_tags: :bypass
                    ).gsub(/\r|\t/,' ').strip
                }.join('\n')
              end
            }
          else
            current_section = nil
            noko.collect { |row|
               unless row.xpath(colspans)&.text.strip.empty?
                 current_section = htmee.decode(row.xpath("td[@colspan=\"#{columns}\"]").text).gsub(/\n|\r|\t/,' ').strip
                 sections[current_section] ||= Array.new
               else
                 if current_section
                   sections[current_section] << (1..columns).map { |i|
                      ReverseMarkdown.convert(
                        htmee.decode(row.at_xpath("td[#{i}]")&.children&.to_s.strip || row.at_xpath("td[#{i}]")&.to_s.strip), unknown_tags: :bypass
                      ).strip
                   }.join(': ')
                 end
               end
             }
          end
        }
      end

      def crawler_table_to_list(noko, table_path, excluded_terms: [])
        htmee = HTMLEntities.new(:expanded)
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
        String.new.tap { |list|
          list << '<ul>'
          list << Array.new.tap { |lines|
            noko.xpath(table_path).collect { |td|
              line = if td.xpath('table/tr/td').count > 0
                crawler_table(td, 'table/tr', 2)
              else
                raw_ln = ReverseMarkdown.convert(td&.children&.to_s.strip, unknown_tags: :bypass)
                raw_ln unless raw_ln.empty? || excluded_terms.include?(raw_ln)
              end
              if line&.is_a? String
                lines << "<li>#{htmee.decode(markdown.render line)}</li>"
              elsif line.is_a? Hash
                line&.map { |key, value|
                  lines << "<li><strong>#{key}</strong>: #{value} </li>" unless excluded_terms.include?(key) || excluded_terms.include?(value)
                }.join("\n")
              else
                line&.map { |v|
                  lines << "<li>#{v}</li>" unless excluded_terms.include?(v)
                }.join("\n")
              end
            }
          }.join("\n")
          list << '</ul>'
        }
      end


    end
  end
end
