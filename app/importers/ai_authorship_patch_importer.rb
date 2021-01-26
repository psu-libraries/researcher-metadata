require 'activity_insight_importer'

class AIAuthorshipPatchImporter < ActivityInsightImporter
  def call
    pbar = ProgressBar.create(title: 'Importing Activity Insight Data', total: ai_users.count) unless Rails.env.test?

    ai_users.each do |aiu|
      pbar.increment unless Rails.env.test?
      details = ai_user_detail(aiu.raw_webaccess_id)

      details.publications.each do |pub|
        pi = PublicationImport.find_by(source: ActivityInsightImporter::IMPORT_SOURCE, source_identifier: pub.activity_insight_id)
        if pi
          pub_record = pi.publication

          pub.faculty_authors.each do |author|
            user = User.find_by(activity_insight_identifier: author.activity_insight_user_id)
            if user
              authorship = Authorship.find_by(user: user, publication: pub_record)

              unless authorship
                Authorship.create!(
                  user: user,
                  publication: pub_record,
                  author_number: pub.contributors.index(author) + 1,
                  role: author.role
                )
              end
            end
          end
        end
      end
    end

    pbar.finish unless Rails.env.test?
  end
end
