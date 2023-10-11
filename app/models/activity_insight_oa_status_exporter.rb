# frozen_string_literal: true

class ActivityInsightOAStatusExporter < ActivityInsightExporter
  class ExportFailed < RuntimeError; end

  def initialize(file_id, export_status)
    super()
    @file = ActivityInsightOAFile.find(file_id)
    @export_status = export_status
  end

  def export
    response = HTTParty.post webservice_url, body: to_xml(file),
                                             headers: { 'Content-type' => 'text/xml' }, basic_auth: auth, timeout: 180
    unless response.code == 200
      file.exported_oa_status_to_activity_insight = false
      file.save!
      raise ExportFailed.new(response.body)
    end
  end

  private

    attr_accessor :file, :export_status

    def to_xml(file)
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.Data do
          user = file.user
          xml.Record('username' => user.webaccess_id) do
            xml.INTELLCONT('id' => file.intellcont_id) do
              xml.POST_FILE('id' => file.post_file_id) do
                xml.ACCESIBLE(export_status)
              end
              xml.RMD_ID(file.publication.id, access: 'READ_ONLY')
            end
          end
        end
      end
      builder.to_xml
    end

    def webservice_url
      Settings.activity_insight.export_url
    end
end
