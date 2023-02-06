# frozen_string_literal: true

require 'pdf-reader'

class ScholarspherePdfFileVersion
  attr_accessor :file_path, :filename, :publication, :content

  def initialize(file_path:, filename:, publication:)
    @file_path = file_path
    @filename = filename
    @publication = publication
    @content = process_content
  end

  def version
    calculate_score

    if @score.positive?
      I18n.t('file_versions.published_version')
    elsif @score.negative?
      I18n.t('file_versions.accepted_version')
    end
  end

  private

    def process_content
      reader = PDF::Reader.new(file_path)
      words = reader.pages.map { |page| page.text.split.first(500).flatten }
      words.join(' ')
    end

    def publication_title
      publication&.title
    end

    def publication_meta
      {
        year: publication&.year,
        doi: publication&.doi
        # TODO: publisher: publication&.publisher
      }
    end

    def calculate_score
      @score = 0

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
        what_to_match = what_to_search.split('<<')[1].split('>>').first
        if publication_meta[what_to_match.downcase]
          what_to_search = what_to_search.gsub("<<#{what_to_match}>>", publication_meta[what_to_match.downcase])
        end
      end

      what_to_search
    end

    def match_content(what_to_search, where_to_search, how_to_search)
      if how_to_search == 'string'
        if where_to_search == 'file'
          content.include?(what_to_search)
        else
          publication_title&.include?(what_to_search) || filename&.include?(what_to_search)
        end
      else
        re = Regexp.new(what_to_search, 'gium')
        if where_to_search == 'file'
          content.downcase.match?(re)
        else
          publication_title&.match?(re) || filename&.match?(re)
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
end
