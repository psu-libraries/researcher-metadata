# frozen_string_literal: true

require 'component/component_spec_helper'

describe PurePublicationImporter do
  let(:importer) { described_class.new }
  let(:http_response_1) { File.read(filename_1) }
  let(:http_response_2) { File.read(filename_2) }
  let(:http_error_response) { File.read(error_filename) }
  let(:filename_1) { Rails.root.join('spec', 'fixtures', 'pure_publications_1.json') }
  let(:filename_2) { Rails.root.join('spec', 'fixtures', 'pure_publications_2.json') }
  let(:error_filename) { Rails.root.join('spec', 'fixtures', 'pure_not_found_error.json') }

  let!(:pub1auth1) { create(:user, pure_uuid: '5ec8ce05-0912-4d68-8633-c5618a3cf15d') }
  let!(:pub2auth4) { create(:user, pure_uuid: 'dc40be59-e778-404c-aaed-eddb9a992cb8') }
  let!(:pub3auth2) { create(:user, pure_uuid: '82195bc6-c5cd-479e-b6f8-545f0f0555ba') }

  let(:found_pub1) { PublicationImport.find_by(source: 'Pure', source_identifier: 'e1b21d75-4579-4efc-9fcc-dcd9827ee51a') }
  let(:found_pub2) { PublicationImport.find_by(source: 'Pure', source_identifier: 'bfc570c3-10d8-451e-9145-c370d6f01c64') }
  let(:found_pub3) { PublicationImport.find_by(source: 'Pure', source_identifier: 'fc65cb12-5a98-477e-b2f8-e191e0aae9d0') }
  let(:found_pub4) { PublicationImport.find_by(source: 'Pure', source_identifier: 'e1b21d75-4579-4efc-9fcc-dcd9827ee51b') }

  let!(:journal) { create(:journal,
                          pure_uuid: '6bd3ad47-c2bf-44cb-9d79-85d9fe14550f') }

  before do
    allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/research-outputs?navigationLink=false&size=1&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_1

    allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/research-outputs?navigationLink=false&size=500&offset=0',
                                          headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_response_2

    allow(DOIVerificationJob).to receive(:perform_later)
  end

  describe '#call' do
    let!(:duplicate_pub1) { create(:publication, title: 'Third Test Publication With a Really Unique Title', visible: true) }
    let!(:duplicate_pub2) { create(:publication, title: 'Third Test Publication With a Really Unique Title', visible: true) }

    context 'when the API endpoint is found' do
      let(:email) { spy 'notification email' }

      before do
        allow(AdminNotificationsMailer).to receive(:pure_import_error).and_return email
      end

      it 'does not send a notification email to RMD admins' do
        importer.call
        expect(email).not_to have_received(:deliver_now)
      end

      context 'when no publication import records exist in the database' do
        it 'creates a new publication import record for each Published or Accepted/In press publication in the imported data' do
          expect { importer.call }.to change(PublicationImport, :count).by 4
        end

        it 'creates a new publication record for each Published or Accepted/In press publication in the imported data' do
          expect { importer.call }.to change(Publication, :count).by 4
        end

        it 'creates a new contributor name record for each author on each publication' do
          expect { importer.call }.to change(ContributorName, :count).by 13
        end

        it 'creates a new authorship record for each author who is a Penn State user on each publication' do
          expect { importer.call }.to change(Authorship, :count).by 4
        end

        it 'saves the correct data for each publication import' do
          importer.call

          expect(found_pub1.source_updated_at).to eq Time.parse('2018-03-14T20:47:06.357+0000')
          expect(found_pub2.source_updated_at).to eq Time.parse('2018-05-01T01:10:03.735+0000')
          expect(found_pub3.source_updated_at).to eq Time.parse('2020-02-01T01:01:19.993+0000')
        end

        it 'saves the correct data for each publication' do
          importer.call

          p1 = found_pub1.publication
          p2 = found_pub2.publication
          p3 = found_pub3.publication

          expect(p1.title).to eq 'The First Publication: From Pure'
          expect(p2.title).to eq 'Third Test Publication With a Really Unique Title'
          expect(p3.title).to eq 'Chronic hip pain as a presenting symptom in pelvic congestion syndrome'

          expect(p1.secondary_title).to be_nil
          expect(p2.secondary_title).to be_nil
          expect(p3.secondary_title).to be_nil

          expect(p1.publication_type).to eq 'Academic Journal Article'
          expect(p2.publication_type).to eq 'Academic Journal Article'
          expect(p3.publication_type).to eq 'Letter'

          expect(p1.page_range).to eq '91-95'
          expect(p2.page_range).to eq '665-680'
          expect(p3.page_range).to eq '753-755'

          expect(p1.volume).to eq '6'
          expect(p2.volume).to eq '30'
          expect(p3.volume).to eq '24'

          expect(p1.issue).to eq '2'
          expect(p2.issue).to eq '3'
          expect(p3.issue).to eq '5'

          expect(p1.journal).to be_nil
          expect(p2.journal).to eq journal
          expect(p3.journal).to be_nil

          expect(p1.issn).to eq '0962-1849'
          expect(p2.issn).to eq '0272-4634'
          expect(p3.issn).to eq '1051-0443'

          expect(p1.status).to eq 'Published'
          expect(p2.status).to eq 'In Press'
          expect(p3.status).to eq 'Published'

          expect(p1.published_on).to eq Date.new(1997, 1, 1)
          expect(p2.published_on).to eq Date.new(2010, 5, 1)
          expect(p3.published_on).to eq Date.new(2013, 5, 1)

          expect(p1.total_scopus_citations).to eq 2
          expect(p2.total_scopus_citations).to eq 32
          expect(p3.total_scopus_citations).to eq 6

          expect(p1.abstract).to be_nil
          expect(p2.abstract).to eq '<p>This is the third abstract.</p>'
          expect(p3.abstract).to be_nil

          expect(p1.visible).to be true
          expect(p2.visible).to be true
          expect(p3.visible).to be true

          expect(p1.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
          expect(p2.doi).to be_nil
          expect(p3.doi).to eq 'https://doi.org/10.1016/j.jvir.2013.01.004'
        end

        it 'saves the correct data for each contributor name' do
          importer.call

          p1 = found_pub1.publication
          p2 = found_pub2.publication
          p3 = found_pub3.publication

          expect(p1.contributor_names.count).to eq 2
          expect(p2.contributor_names.count).to eq 5
          expect(p3.contributor_names.count).to eq 4

          expect(p1.contributor_names.find_by(first_name: 'Firstpub R.',
                                              middle_name: nil,
                                              last_name: 'Firstauthor',
                                              user: pub1auth1,
                                              position: 1)).not_to be_nil
          expect(p1.contributor_names.find_by(first_name: 'Firstpub',
                                              middle_name: nil,
                                              last_name: 'Secondauthor',
                                              user: nil,
                                              position: 2)).not_to be_nil

          expect(p2.contributor_names.find_by(first_name: 'Thirdpub A.',
                                              middle_name: nil,
                                              last_name: 'Firstauthor',
                                              user: nil,
                                              position: 1)).not_to be_nil
          expect(p2.contributor_names.find_by(first_name: 'Thirdpub',
                                              middle_name: nil,
                                              last_name: 'Secondauthor',
                                              user: pub3auth2,
                                              position: 2)).not_to be_nil
          expect(p2.contributor_names.find_by(first_name: 'Thirdpub',
                                              middle_name: nil,
                                              last_name: 'Thirdauthor',
                                              user: nil,
                                              position: 3)).not_to be_nil
          expect(p2.contributor_names.find_by(first_name: 'Thirdpub',
                                              middle_name: nil,
                                              last_name: 'Fourthauthor',
                                              user: nil,
                                              position: 4)).not_to be_nil
          expect(p2.contributor_names.find_by(first_name: 'Thirdpub',
                                              middle_name: nil,
                                              last_name: 'Fifthauthor',
                                              user: nil,
                                              position: 5)).not_to be_nil

          expect(p3.contributor_names.find_by(first_name: 'Nonarticlepub',
                                              middle_name: nil,
                                              last_name: 'Firstauthor',
                                              user: nil,
                                              position: 1)).not_to be_nil
          expect(p3.contributor_names.find_by(first_name: 'Nonarticlepub',
                                              middle_name: nil,
                                              last_name: 'Secondauthor',
                                              user: nil,
                                              position: 2)).not_to be_nil
          expect(p3.contributor_names.find_by(first_name: 'Nonarticlepub',
                                              middle_name: nil,
                                              last_name: 'Thirdauthor',
                                              user: nil,
                                              position: 3)).not_to be_nil
          expect(p3.contributor_names.find_by(first_name: 'Nonarticlepub',
                                              middle_name: nil,
                                              last_name: 'Fourthauthor',
                                              user: pub2auth4,
                                              position: 4)).not_to be_nil
        end

        it 'saves the correct data for each authorship' do
          importer.call

          expect(Authorship.find_by(publication: found_pub1.publication,
                                    user: pub1auth1,
                                    author_number: 1)).not_to be_nil

          expect(Authorship.find_by(publication: found_pub2.publication,
                                    user: pub3auth2,
                                    author_number: 2)).not_to be_nil

          expect(Authorship.find_by(publication: found_pub3.publication,
                                    user: pub2auth4,
                                    author_number: 4)).not_to be_nil
        end

        it 'groups possible duplicates of new publication records' do
          expect { importer.call }.to change(DuplicatePublicationGroup, :count).by 1

          p2 = found_pub2.publication
          group = p2.duplicate_group

          expect(group.publications).to match_array [p2, duplicate_pub1, duplicate_pub2]
        end

        it 'hides existing publications that might be duplicates' do
          importer.call

          p2 = found_pub2.publication

          expect(p2.visible).to be true
          expect(duplicate_pub1.reload.visible).to be false
          expect(duplicate_pub2.reload.visible).to be false
        end

        it 'runs the DOI verification' do
          importer.call
          pub_import = PublicationImport.find_by(source: 'Pure',
                                         source_identifier: 'e1b21d75-4579-4efc-9fcc-dcd9827ee51a').publication
          expect(DOIVerificationJob).to have_received(:perform_later).with(pub_import.id)
        end
      end

      context 'when a publication record and a publication import record already exist for one of the publications in the imported data' do
        let!(:existing_import) { create(:publication_import,
                                        source: 'Pure',
                                        source_identifier: 'e1b21d75-4579-4efc-9fcc-dcd9827ee51a',
                                        source_updated_at: Time.new(1999, 12, 31, 23, 59, 59),
                                        publication: existing_pub) }
        let!(:existing_import2) { create(:publication_import,
                                         source: 'Pure',
                                         source_identifier: 'e1b21d75-4579-4efc-9fcc-dcd9827ee51b',
                                         source_updated_at: Time.new(1999, 12, 30, 23, 59, 59),
                                         publication: existing_pub2) }
        let(:existing_pub) { create(:publication,
                                    updated_by_user_at: updated_ts,
                                    title: 'Existing Title',
                                    secondary_title: 'Existing Subtitle',
                                    publication_type: 'Journal Article',
                                    journal: existing_journal,
                                    page_range: 'existing range',
                                    volume: 'existing volume',
                                    issue: 'existing issue',
                                    issn: 'existing issn',
                                    status: 'In Press',
                                    published_on: Date.new(2018, 8, 22),
                                    total_scopus_citations: 1,
                                    abstract: 'existing abstract',
                                    visible: false,
                                    doi: doi) }
        let(:existing_pub2) { create(:publication,
                                     updated_by_user_at: updated_ts,
                                     title: 'Existing Title2',
                                     secondary_title: 'Existing Subtitle2',
                                     publication_type: 'Journal Article',
                                     journal: existing_journal,
                                     page_range: 'existing range2',
                                     volume: 'existing volume2',
                                     issue: 'existing issue2',
                                     issn: 'existing issn2',
                                     status: 'Published',
                                     published_on: Date.new(2018, 9, 22),
                                     total_scopus_citations: 1,
                                     abstract: 'existing abstract2',
                                     visible: false,
                                     doi: doi2) }
        let(:doi) { 'https://doi.org/10.000/existing' }
        let(:doi2) { 'https://doi.org/10.000/existing2' }
        let(:existing_journal) { create(:journal) }

        context 'when the existing publication record has not been manually updated' do
          let(:updated_ts) { nil }

          it 'creates a new publication import record for each new Published or Accepted/In press publication in the imported data' do
            expect { importer.call }.to change(PublicationImport, :count).by 2
          end

          it 'creates a new publication record for each new Published or Accepted/In press publication in the imported data' do
            expect { importer.call }.to change(Publication, :count).by 2
          end

          context 'when no contributor records exist' do
            it 'creates a new contributor record for each author on each publication' do
              expect { importer.call }.to change(ContributorName, :count).by 13
              expect(existing_pub.contributor_names.count).to eq 2

              expect(existing_pub.contributor_names.find_by(first_name: 'Firstpub R.',
                                                            middle_name: nil,
                                                            last_name: 'Firstauthor',
                                                            user: pub1auth1,
                                                            position: 1)).not_to be_nil
              expect(existing_pub.contributor_names.find_by(first_name: 'Firstpub',
                                                            middle_name: nil,
                                                            last_name: 'Secondauthor',
                                                            user: nil,
                                                            position: 2)).not_to be_nil
            end
          end

          context 'when contributor records already exist for the existing publication' do
            let!(:existing_contributor) { create(:contributor_name,
                                                 first_name: 'An',
                                                 middle_name: 'Existing',
                                                 last_name: 'Contributor',
                                                 position: 3,
                                                 publication: existing_pub) }

            it 'replaces the existing contributor records with new records from the import data' do
              expect { importer.call }.to change(ContributorName, :count).by 12
              expect(existing_pub.contributor_names.count).to eq 2

              expect(existing_pub.contributor_names.find_by(first_name: 'Firstpub R.',
                                                            middle_name: nil,
                                                            last_name: 'Firstauthor',
                                                            user: pub1auth1,
                                                            position: 1)).not_to be_nil
              expect(existing_pub.contributor_names.find_by(first_name: 'Firstpub',
                                                            middle_name: nil,
                                                            last_name: 'Secondauthor',
                                                            user: nil,
                                                            position: 2)).not_to be_nil
            end
          end

          context 'when no authorship records exist' do
            it 'creates a new authorship record for each author who is a Penn State user on each publication' do
              expect { importer.call }.to change(Authorship, :count).by 4

              expect(Authorship.find_by(publication: found_pub1.publication,
                                        user: pub1auth1,
                                        author_number: 1,
                                        confirmed: true)).not_to be_nil

              expect(Authorship.find_by(publication: found_pub2.publication,
                                        user: pub3auth2,
                                        author_number: 2,
                                        confirmed: true)).not_to be_nil

              expect(Authorship.find_by(publication: found_pub3.publication,
                                        user: pub2auth4,
                                        author_number: 4,
                                        confirmed: true)).not_to be_nil
            end
          end

          context 'when an authorship record already exists for the existing publication and user' do
            let!(:existing_auth) { create(:authorship,
                                          user: pub1auth1,
                                          publication: existing_pub,
                                          author_number: 6) }

            it 'does not create a new authorship record' do
              expect { importer.call }.to change(Authorship, :count).by 3
            end

            it 'updates the existing authorship record with the new authorship data' do
              importer.call
              expect(existing_auth.reload.author_number).to eq 1
            end
          end

          it 'updates the existing publication import with the new data' do
            importer.call
            expect(existing_import.reload.source_updated_at).to eq Time.parse('2018-03-14T20:47:06.357+0000')
          end

          it 'updates the existing publication with the new data' do
            importer.call

            updated_pub = existing_pub.reload

            expect(updated_pub.title).to eq 'The First Publication: From Pure'
            expect(updated_pub.secondary_title).to be_nil
            expect(updated_pub.publication_type).to eq 'Academic Journal Article'
            expect(updated_pub.page_range).to eq '91-95'
            expect(updated_pub.volume).to eq '6'
            expect(updated_pub.issue).to eq '2'
            expect(updated_pub.journal).to be_nil
            expect(updated_pub.issn).to eq '0962-1849'
            expect(updated_pub.status).to eq 'Published'
            expect(updated_pub.published_on).to eq Date.new(1997, 1, 1)
            expect(updated_pub.total_scopus_citations).to eq 2
            expect(updated_pub.abstract).to be_nil
            expect(updated_pub.visible).to be true
            expect(updated_pub.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
          end

          it 'creates new publications with the correct data' do
            importer.call

            new_pub = found_pub2.publication

            expect(new_pub.title).to eq 'Third Test Publication With a Really Unique Title'
            expect(new_pub.secondary_title).to be_nil
            expect(new_pub.publication_type).to eq 'Academic Journal Article'
            expect(new_pub.page_range).to eq '665-680'
            expect(new_pub.volume).to eq '30'
            expect(new_pub.issue).to eq '3'
            expect(new_pub.journal).to eq journal
            expect(new_pub.issn).to eq '0272-4634'
            expect(new_pub.status).to eq 'In Press'
            expect(new_pub.published_on).to eq Date.new(2010, 5, 1)
            expect(new_pub.total_scopus_citations).to eq 32
            expect(new_pub.abstract).to eq '<p>This is the third abstract.</p>'
            expect(new_pub.visible).to be true
            expect(new_pub.doi).to be_nil
          end

          it 'groups possible duplicates of new publication records' do
            expect { importer.call }.to change(DuplicatePublicationGroup, :count).by 1

            p2 = found_pub2.publication
            group = p2.duplicate_group

            expect(group.publications).to match_array [p2, duplicate_pub1, duplicate_pub2]
          end

          it 'hides existing publications that might be duplicates' do
            importer.call

            p2 = found_pub2.publication

            expect(p2.visible).to be true
            expect(duplicate_pub1.reload.visible).to be false
            expect(duplicate_pub2.reload.visible).to be false
          end
        end

        context 'when the existing publication record has been manually updated' do
          let(:updated_ts) { Time.now }
          let!(:new_journal) { create(:journal,
                                      pure_uuid: 'e72f86d9-88a4-4dea-9b0a-8cb1cccb82ad') }

          it 'creates a new publication import record for each new Published or Accepted/In press publication in the imported data' do
            expect { importer.call }.to change(PublicationImport, :count).by 2
          end

          it 'creates a new publication record for each new Published or Accepted/In press publication in the imported data' do
            expect { importer.call }.to change(Publication, :count).by 2
          end

          context 'when no contributor records exist' do
            it 'creates a new contributor record for each author on each new publication only' do
              expect { importer.call }.to change(ContributorName, :count).by 9
              expect(existing_pub.contributor_names.count).to eq 0
            end
          end

          context 'when contributor records already exist for the existing publication' do
            let!(:existing_contributor) { create(:contributor_name,
                                                 first_name: 'An',
                                                 middle_name: 'Existing',
                                                 last_name: 'Contributor',
                                                 position: 3,
                                                 publication: existing_pub) }

            it 'does not modify existing contributor records on the existing publication' do
              expect { importer.call }.to change(ContributorName, :count).by 9
              expect(existing_pub.contributor_names.count).to eq 1

              expect(existing_pub.contributor_names.find_by(first_name: 'An',
                                                            middle_name: 'Existing',
                                                            last_name: 'Contributor',
                                                            position: 3)).not_to be_nil
            end
          end

          context 'when no authorship records exist' do
            it 'creates a new authorship record for each author who is a Penn State user on each new publication only' do
              expect { importer.call }.to change(Authorship, :count).by 2

              expect(Authorship.find_by(publication: found_pub1.publication,
                                        user: pub1auth1,
                                        author_number: 1)).to be_nil

              expect(Authorship.find_by(publication: found_pub2.publication,
                                        user: pub3auth2,
                                        author_number: 2,
                                        confirmed: true)).not_to be_nil

              expect(Authorship.find_by(publication: found_pub1.publication,
                                        user: pub2auth4,
                                        author_number: 4)).to be_nil
            end
          end

          context 'when an authorship record already exists for the existing publication and user' do
            let!(:existing_auth) { create(:authorship,
                                          user: pub1auth1,
                                          publication: existing_pub,
                                          author_number: 6) }

            it 'does not create a new authorship record' do
              expect { importer.call }.to change(Authorship, :count).by 2
            end

            it 'does not update the existing authorship record with new authorship data' do
              importer.call
              expect(existing_auth.reload.author_number).to eq 6
            end
          end

          it 'updates the existing publication import with the new data' do
            importer.call
            expect(existing_import.reload.source_updated_at).to eq Time.parse('2018-03-14T20:47:06.357+0000')
          end

          context 'when the existing publication already has a DOI' do
            it 'updates only the Scopus citation count, title, and status on the existing publication' do
              importer.call

              existing_pub_reloaded = existing_pub.reload
              existing_pub2_reloaded = existing_pub2.reload

              expect(existing_pub_reloaded.title).to eq 'The First Publication: From Pure'
              expect(existing_pub_reloaded.secondary_title).to eq 'Existing Subtitle'
              expect(existing_pub_reloaded.publication_type).to eq 'Journal Article'
              expect(existing_pub_reloaded.page_range).to eq 'existing range'
              expect(existing_pub_reloaded.volume).to eq 'existing volume'
              expect(existing_pub_reloaded.issue).to eq 'existing issue'
              expect(existing_pub_reloaded.journal).to eq new_journal
              expect(existing_pub_reloaded.issn).to eq 'existing issn'
              expect(existing_pub_reloaded.status).to eq 'Published'
              expect(existing_pub_reloaded.published_on).to eq Date.new(2018, 8, 22)
              expect(existing_pub_reloaded.total_scopus_citations).to eq 2
              expect(existing_pub_reloaded.abstract).to eq 'existing abstract'
              expect(existing_pub_reloaded.visible).to be false
              expect(existing_pub_reloaded.doi).to eq 'https://doi.org/10.000/existing'

              expect(existing_pub2_reloaded.status).to eq 'Published'
            end
          end

          context 'when the existing publication does not have a DOI' do
            let(:doi) { nil }

            it 'updates only the Scopus citation count and DOI on the existing publication' do
              importer.call

              existing_pub_reloaded = existing_pub.reload

              expect(existing_pub_reloaded.title).to eq 'The First Publication: From Pure'
              expect(existing_pub_reloaded.secondary_title).to eq 'Existing Subtitle'
              expect(existing_pub_reloaded.publication_type).to eq 'Journal Article'
              expect(existing_pub_reloaded.page_range).to eq 'existing range'
              expect(existing_pub_reloaded.volume).to eq 'existing volume'
              expect(existing_pub_reloaded.issue).to eq 'existing issue'
              expect(existing_pub_reloaded.journal).to eq new_journal
              expect(existing_pub_reloaded.issn).to eq 'existing issn'
              expect(existing_pub_reloaded.status).to eq 'Published'
              expect(existing_pub_reloaded.published_on).to eq Date.new(2018, 8, 22)
              expect(existing_pub_reloaded.total_scopus_citations).to eq 2
              expect(existing_pub_reloaded.abstract).to eq 'existing abstract'
              expect(existing_pub_reloaded.visible).to be false
              expect(existing_pub_reloaded.doi).to eq 'https://doi.org/10.1016/S0962-1849(05)80014-9'
            end
          end

          it 'creates new publications with the correct data' do
            importer.call

            new_pub = found_pub2.publication

            expect(new_pub.title).to eq 'Third Test Publication With a Really Unique Title'
            expect(new_pub.secondary_title).to be_nil
            expect(new_pub.publication_type).to eq 'Academic Journal Article'
            expect(new_pub.page_range).to eq '665-680'
            expect(new_pub.volume).to eq '30'
            expect(new_pub.issue).to eq '3'
            expect(new_pub.journal).to eq journal
            expect(new_pub.issn).to eq '0272-4634'
            expect(new_pub.status).to eq 'In Press'
            expect(new_pub.published_on).to eq Date.new(2010, 5, 1)
            expect(new_pub.total_scopus_citations).to eq 32
            expect(new_pub.abstract).to eq '<p>This is the third abstract.</p>'
            expect(new_pub.visible).to be true
            expect(new_pub.doi).to be_nil
          end

          it 'groups possible duplicates of new publication records' do
            expect { importer.call }.to change(DuplicatePublicationGroup, :count).by 1

            p2 = found_pub2.publication
            group = p2.duplicate_group

            expect(group.publications).to match_array [p2, duplicate_pub1, duplicate_pub2]
          end

          it 'hides existing publications that might be duplicates' do
            importer.call

            p2 = found_pub2.publication

            expect(p2.visible).to be true
            expect(duplicate_pub1.reload.visible).to be false
            expect(duplicate_pub2.reload.visible).to be false
          end
        end
      end
    end

    context 'when the API endpoint is not found' do
      let(:email) { spy 'notification email' }

      before do
        allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/research-outputs?navigationLink=false&size=1&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response

        allow(HTTParty).to receive(:get).with('https://pure.psu.edu/ws/api/524/research-outputs?navigationLink=false&size=500&offset=0',
                                              headers: { 'api-key' => 'fake_api_key', 'Accept' => 'application/json' }).and_return http_error_response
        allow(AdminNotificationsMailer).to receive(:pure_import_error).and_return email
        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'captures and logs the error' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(PureImporter::ServiceNotFound),
          metadata: {}
        )
      end

      it 'sends a notification email to RMD admins' do
        importer.call
        expect(email).to have_received(:deliver_now)
      end
    end

    context 'when there is an error within the loop' do
      before do
        allow(PublicationImport).to receive(:find_by).and_raise(ZeroDivisionError)

        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error and moves on' do
        importer.call

        expect(ImporterErrorLog).to have_received(:log_error).with(
          importer_class: described_class,
          error: an_instance_of(ZeroDivisionError),
          metadata: a_hash_including(
            publication: an_instance_of(Hash)
          )
        ).at_least(2).times
      end
    end
  end
end
