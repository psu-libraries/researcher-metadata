require 'component/component_spec_helper'

describe PurePublicationImporter do
  let(:importer) { PurePublicationImporter.new(dirname: dirname) }
  let!(:pub1auth1) { create :user, pure_uuid: '5ec8ce05-0912-4d68-8633-c5618a3cf15d'}
  let!(:pub2auth4) { create :user, pure_uuid: 'dc40be59-e778-404c-aaed-eddb9a992cb8'} # second publication is not an article
  let!(:pub3auth2) { create :user, pure_uuid: '82195bc6-c5cd-479e-b6f8-545f0f0555ba'}

  let(:found_pub1) { PublicationImport.find_by(source: 'Pure', source_identifier: 'e1b21d75-4579-4efc-9fcc-dcd9827ee51a') }
  let(:found_pub2) { PublicationImport.find_by(source: 'Pure', source_identifier: 'bfc570c3-10d8-451e-9145-c370d6f01c64') }

  describe '#call' do
    context "when given a directory containing well-formed .json files of valid publication data from Pure" do
      let(:dirname) { Rails.root.join('spec', 'fixtures', 'pure_publications') }

      context "when no publication records exist in the database" do
        it "creates a new publication record for each object in the .json files that is an article" do
          expect { importer.call }.to change { Publication.count }.by 2 # There are 3 publications, but one is a letter
        end

        it "creates a new publication import record for each object in the .json files that is an article" do
          expect { importer.call }.to change { PublicationImport.count }.by 2
        end

        it "creates a new contributor record for each author on each article" do
          expect { importer.call }.to change { Contributor.count }.by 7
        end

        it "creates a new authorship record for each author on each article who is a Penn State user" do
          expect { importer.call }.to change { Authorship.count }.by 2 # There are 2 articles, each with one PSU author
        end

        it "saves the correct data for each publication import" do
          importer.call

          expect(found_pub1.source_updated_at).to eq Time.parse('2018-03-14T20:47:06.357+0000')
          expect(found_pub2.source_updated_at).to eq Time.parse('2018-05-01T01:10:03.735+0000')
        end

        it "saves the correct data for each publication" do
          importer.call

          p1 = found_pub1.publication
          p2 = found_pub2.publication

          expect(p1.title).to eq 'The First Publication'
          expect(p2.title).to eq 'The Third Pure Publication'

          expect(p1.secondary_title).to eq 'From Pure'
          expect(p2.secondary_title).to eq nil

          expect(p1.publication_type).to eq 'Academic Journal Article'
          expect(p2.publication_type).to eq 'Academic Journal Article'

          expect(p1.page_range).to eq '91-95'
          expect(p2.page_range).to eq '665-680'

          expect(p1.volume).to eq '6'
          expect(p2.volume).to eq '30'

          expect(p1.issue).to eq '2'
          expect(p2.issue).to eq '3'

          expect(p1.journal_title).to eq 'Applied and Preventive Psychology'
          expect(p2.journal_title).to eq 'Journal of Vertebrate Paleontology'

          expect(p1.issn).to eq '0962-1849'
          expect(p2.issn).to eq '0272-4634'

          expect(p1.status).to eq 'Published'
          expect(p2.status).to eq 'Published'

          expect(p1.published_on).to eq Date.new(1997, 1, 1)
          expect(p2.published_on).to eq Date.new(2010, 5, 1)

          expect(p1.citation_count).to eq 2
          expect(p2.citation_count).to eq 32
        end

        it "saves the correct data for each contributor" do
          importer.call

          p1 = found_pub1.publication
          p2 = found_pub2.publication

          expect(p1.contributors.count).to eq 2
          expect(p2.contributors.count).to eq 5

          expect(p1.contributors.find_by(first_name: 'Firstpub R.',
                                         middle_name: nil,
                                         last_name: 'Firstauthor',
                                         position: 1)).not_to be_nil
          expect(p1.contributors.find_by(first_name: 'Firstpub',
                                         middle_name: nil,
                                         last_name: 'Secondauthor',
                                         position: 2)).not_to be_nil

          expect(p2.contributors.find_by(first_name: 'Thirdpub A.',
                                         middle_name: nil,
                                         last_name: 'Firstauthor',
                                         position: 1)).not_to be_nil
          expect(p2.contributors.find_by(first_name: 'Thirdpub',
                                         middle_name: nil,
                                         last_name: 'Secondauthor',
                                         position: 2)).not_to be_nil
          expect(p2.contributors.find_by(first_name: 'Thirdpub',
                                         middle_name: nil,
                                         last_name: 'Thirdauthor',
                                         position: 3)).not_to be_nil
          expect(p2.contributors.find_by(first_name: 'Thirdpub',
                                         middle_name: nil,
                                         last_name: 'Fourthauthor',
                                         position: 4)).not_to be_nil
          expect(p2.contributors.find_by(first_name: 'Thirdpub',
                                         middle_name: nil,
                                         last_name: 'Fifthauthor',
                                         position: 5)).not_to be_nil
        end

        it "saves the correct data for each authorship" do
          importer.call

          expect(Authorship.find_by(publication: found_pub1.publication,
                                    user: pub1auth1,
                                    author_number: 1)).not_to be_nil

          expect(Authorship.find_by(publication: found_pub2.publication,
                                    user: pub3auth2,
                                    author_number: 2)).not_to be_nil
        end
      end
    end
  end
end