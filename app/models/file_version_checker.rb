# frozen_string_literal: true

require 'pdf-reader'

class FileVersionChecker
  def initialize(file_path:, publication:)
    @file_path = file_path
    @filename = File.basename(file_path)
    @publication = publication
    @score = 0
    @content = process_content
    calculate_score
  end

  def version
    if contains_arxiv_watermark?(reader) || @score.negative?
      I18n.t('file_versions.accepted_version')
    elsif
      @score.positive?
      I18n.t('file_versions.published_version')
    else
      'unknown'
    end
  end

  def score
    @score
  end

  private

    attr_accessor :file_path, :filename, :publication, :content

    def process_content
      return '' if File.extname(file_path) != '.pdf' || reader.nil?

      begin
        words = []
        reader.pages.each do |page|
          break if words.count >= 500

          words << page.text.split.first(500)
          words.flatten!
        # Formatting issues can cause errors
        # Best to rescue and move to the next page
        rescue StandardError
          next
        end
      rescue PDF::Reader::MalformedPDFError,
             PDF::Reader::InvalidObjectError,
             PDF::Reader::EncryptedPDFError
        return ''
      end

      words.flatten.join(' ')
    end

    def reader
      @reader ||= PDF::Reader.new(file_path)
    rescue PDF::Reader::MalformedPDFError,
           PDF::Reader::InvalidObjectError,
           PDF::Reader::EncryptedPDFError
      @reader = nil
    end

    def calculate_score
      lines&.each do |line|
        process_line(line)
      end
    end

    def lines
      csv_path = File.join('config', 'file_version_checking_rules.csv')

      if File.exist?(csv_path)
        CSV.parse(File.read(csv_path), headers: true)
      else
        raise "Error: #{csv_path} does not exist or cannot be read."
      end
    end

    def process_line(line)
      what_to_search = process_wts(line['what to search'])
      where_to_search = line['where to search']
      how_to_search = line['how to search']
      indication = line['what it Indicates']&.downcase

      matched = match_content(what_to_search, where_to_search, how_to_search)

      process_indication(indication, matched)
    end

    def process_wts(what_to_search)
      if what_to_search.include?('<<') && what_to_search.include?('>>')
        # Insert publication metadata here if '<<' and '>>' present
        what_to_match = what_to_search.split('<<')[1].split('>>').first
        if pub_meta[what_to_match.downcase.to_sym]
          what_to_search = what_to_search.gsub("<<#{what_to_match}>>", pub_meta[what_to_match.downcase.to_sym].to_s).squish
        end
      end

      what_to_search.strip
    end

    def match_content(what_to_search, where_to_search, how_to_search)
      if how_to_search == 'string'
        if where_to_search == 'file'
          content.include?(what_to_search)
        else
          filename&.include?(what_to_search)
        end
      else
        re = Regexp.new(what_to_search, 'gium')
        if where_to_search == 'file'
          content.downcase.match?(re)
        else
          filename&.match?(re)
        end
      end
    end

    def process_indication(indication, matched)
      if matched
        if ['publisher pdf', 'publishedversion'].include?(indication)
          @score += 1
        else
          @score -= 1
        end
      end
    end

    def pub_meta
      {
        year: publication.year,
        doi: publication.doi,
        publisher: publication.preferred_publisher_name
      }
    end

    def contains_arxiv_watermark?(reader)
      if !reader.nil? && !reader.objects[8].nil? && !reader.objects[8][:A].nil? && !reader.objects[8][:A][:URI].nil?
        reader.objects[8][:A][:URI].include?('arxiv.org')
      end
    end
end
