class AiPublicationExportJob
  include SuckerPunch::Job

  def perform(publications, target)
    # TODO: Switch 'beta' with target when ready to go to production
    ActivityInsightPublicationExporter.new(publications, 'beta').export
  end
end
