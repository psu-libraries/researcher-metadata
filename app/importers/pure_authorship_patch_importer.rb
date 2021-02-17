class PureAuthorshipPatchImporter < PurePublicationImporter
  def call
    import_files = Dir.children(dirname)
    pbar = ProgressBar.create(title: 'Importing Pure Authorship Data', total: import_files.count) unless Rails.env.test?
    import_files.each do |filename|
      File.open(dirname.join(filename), 'r') do |file|
        MultiJson.load(file)['items'].each do |publication|
          if publication['type']['term']['text'].detect { |t| t['locale'] == 'en_US' }['value'] == "Article"

            ActiveRecord::Base.transaction do
              pi = PublicationImport.find_by(source: PurePublicationImporter::IMPORT_SOURCE,
                                             source_identifier: publication['uuid'])

              p = pi.publication

              authorships = publication['personAssociations'].select do |a|
                !a['authorCollaboration'].present? &&
                  a['personRole']['term']['text'].detect { |t| t['locale'] == 'en_US' }['value'] == 'Author'
              end

              authorships.each_with_index do |a, i|
                if a['person'].present?
                  u = User.find_by(pure_uuid: a['person']['uuid'])

                  if u
                    authorship = Authorship.find_by(user: u, publication: p)

                    unless authorship
                      Authorship.create!(user: u,
                                         publication: p,
                                         author_number: i+1)
                    end
                  end
                end
              end
            end
          end
        end
      end
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
    nil
  end
end
