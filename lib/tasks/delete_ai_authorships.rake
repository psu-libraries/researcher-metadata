  desc 'Delete all Authorship records associated with publications that are associated with an Activity Insight import except for those that are unconfirmed or have been modified by their owners'
  task delete_ai_authorships: :environment do
    Authorship.joins(publication: [:imports]).where(%{publication_imports.source = 'Activity Insight'}).distinct(:id).where(visible_in_profile: true).where(position_in_profile: nil).where(open_access_notification_sent_at: nil).where(%{orcid_resource_identifier IS NULL OR orcid_resource_identifier = ''}).where(updated_by_owner_at: nil).where(%{authorships.id not in (select authorship_id from internal_publication_waivers)}).where(confirmed: true).destroy_all
  end
