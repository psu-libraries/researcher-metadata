# frozen_string_literal: true

require 'pdf-reader'
require 'exiftool_vendored'

class ExifFileVersion
  def initialize(file)
    @file_path = file.path
  end

  def version
    if accepted_manuscript?
      'acceptedVersion'
    elsif final_published_version?
      'publishedVersion'
    end
  end

  private

    def exif
      @exif || Exiftool.new(@file_path).to_hash
    end

    def accepted_manuscript?
      exif[:journal_article_version]&.downcase == 'am'
    end

    def final_published_version?
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

    # TODO: include [name of journal] check
    def subject?
      !exif[:subject].nil? and ['downloaded from', 'journal pre-proof'].any? { |s| exif[:subject].downcase.include? s }
    end

    def rendition_class?
      !exif[:rendition_class].nil? and exif[:rendition_class] == 'proof:pdf'
    end

    def creator?
      !exif[:creator].nil? and ['indesign', 'arbortext', 'elsevier', 'springer'].any? { |c| exif[:creator].downcase.include? c }
    end

    def creator_tool?
      !exif[:creator_tool].nil? and ['indesign', 'arbortext', 'elsevier', 'springer'].any? { |ct| exif[:creator_tool].downcase.include? ct }
    end

    def producer?
      !exif[:producer].nil? and exif[:producer] == 'Project MUSE'
    end
end
