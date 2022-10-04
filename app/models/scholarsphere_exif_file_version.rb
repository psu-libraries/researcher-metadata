# frozen_string_literal: true

require 'pdf-reader'
require 'exiftool_vendored'

class ScholarsphereExifFileVersion
  def initialize(file_path:, journal:)
    @file_path = file_path
    @journal = journal
  end

  ACCEPTED_VERSION = 'acceptedVersion'
  PUBLISHED_VERSION = 'publishedVersion'
  PUBLISHED_VERSION_CREATORS = ['indesign', 'arbortext', 'elsevier', 'springer'].freeze

  def version
    @version ||= if accepted?
                   ACCEPTED_VERSION
                 elsif published?
                   PUBLISHED_VERSION
                 end
  end

  def accepted_version?
    version == ACCEPTED_VERSION
  end

  private

    def exif
      @exif ||= Exiftool.new(@file_path).to_hash
    end

    def accepted?
      exif[:journal_article_version]&.downcase == 'am'
    end

    def published?
      exif[:journal_article_version]&.downcase == 'p' ||
        exif[:journal_article_version]&.downcase == 'vor' ||
        rights_en_gb? ||
        wps_journaldoi? ||
        subject? ||
        rendition_class? ||
        creator? ||
        creator_tool? ||
        producer?
    end

    def rights_en_gb?
      !exif[:rights_en_gb].nil? and
        exif[:rights_en_gb] == 'Not for further distribution unless allowed by the License or with the express written permission of Cambridge University Press.'
    end

    def wps_journaldoi?
      !exif[:wps_journaldoi].nil?
    end

    def subject?
      subjects = ['downloaded from', 'journal pre-proof']
      subjects << @journal unless @journal.nil?
      !exif[:subject].empty? and subjects.any? { |s| exif[:subject].downcase.include? s }
    end

    def rendition_class?
      !exif[:rendition_class].nil? and exif[:rendition_class] == 'proof:pdf'
    end

    def creator?
      !exif[:creator].nil? and PUBLISHED_VERSION_CREATORS.any? { |c| exif[:creator].downcase.include? c }
    end

    def creator_tool?
      !exif[:creator_tool].nil? and PUBLISHED_VERSION_CREATORS.any? { |ct| exif[:creator_tool].downcase.include? ct }
    end

    def producer?
      !exif[:producer].nil? and exif[:producer] == 'Project MUSE'
    end
end
