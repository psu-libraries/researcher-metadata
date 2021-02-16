require 'activity_insight_importer'

class AIAuthorshipPatchImporter < ActivityInsightImporter
  def call
    pbar = ProgressBar.create(title: 'Importing Activity Insight Authorships', total: ai_users.count) unless Rails.env.test?

    ai_users.each do |aiu|
      pbar.increment unless Rails.env.test?
      details = ai_user_detail(aiu.raw_webaccess_id)

      details.publications.each do |pub|
        pi = PublicationImport.find_by(source: ActivityInsightImporter::IMPORT_SOURCE, source_identifier: pub.activity_insight_id)
        if pi
          pub_record = pi.publication

          if pub.faculty_author
            user = User.find_by(activity_insight_identifier: pub.faculty_author.activity_insight_user_id)
            if user
              authorship = Authorship.find_by(user: user, publication: pub_record)

              unless authorship
                Authorship.create!(
                  user: user,
                  publication: pub_record,
                  author_number: pub.contributors.index(pub.faculty_author) + 1,
                  role: pub.faculty_author.role
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
