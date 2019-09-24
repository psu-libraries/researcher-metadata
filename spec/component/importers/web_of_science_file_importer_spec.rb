require 'component/component_spec_helper'

describe WebOfScienceFileImporter do
  let(:importer) { WebOfScienceFileImporter.new(dirname: dirname) }

  describe '#call' do
    context "when given an XML file of publication data from Web of Science with Penn State Journal Articles" do
      let(:dirname) { Rails.root.join('spec', 'fixtures', 'wos_psu_articles') }
      context "when no existing publications match the data" do
        context "when no existing users match the data" do
          context "when no existing grants match the data" do
            it "does not create any new grants" do
              expect { importer.call }.not_to change { Grant.count }
            end
            it "does not create any new publications" do
              expect { importer.call }.not_to change { Publication.count }
            end
            it "does not create any new associations between grants and publications" do
              expect { importer.call }.not_to change { ResearchFund.count }
            end
          end
          context "when existing grants have the same Web of Science agency and identifier" do
            let!(:grant1) { create :grant,
                                   wos_agency_name: 'NSF',
                                   wos_identifier: 'ATMO-0803779'}
            let!(:grant2) { create :grant,
                                   wos_agency_name: 'NIH',
                                   wos_identifier: 'NIH-346346'}
            it "does not create any new grants" do
              expect { importer.call }.not_to change { Grant.count }
            end
            it "does not create any new publications" do
              expect { importer.call }.not_to change { Publication.count }
            end
            it "does not create any new associations between grants and publications" do
              expect { importer.call }.not_to change { ResearchFund.count }
            end
          end
          context "when existing grants match the Web of Science agency and identifier" do
            let!(:grant1) { create :grant,
                                   agency_name: 'National Science Foundation',
                                   identifier: '0803779'}
            let!(:grant2) { create :grant,
                                   wos_agency_name: 'NIH',
                                   wos_identifier: 'NIH-346346'}
            it "does not create any new grants" do
              expect { importer.call }.not_to change { Grant.count }
            end
            it "does not create any new publications" do
              expect { importer.call }.not_to change { Publication.count }
            end
            it "does not create any new associations between grants and publications" do
              expect { importer.call }.not_to change { ResearchFund.count }
            end
          end
        end
        context "when existing users match the data" do
          let!(:u1) { create :user, orcid_identifier: 'https://orcid.org/1234-0003-3051-5678' }
          let!(:u2) { create :user, first_name: 'Jennifer', last_name: 'Testauthor' }
          let!(:u3) { create :user, orcid_identifier: 'https://orcid.org/5678-0003-3051-1234' }
          context "when no existing grants match the data" do
            it "creates new grants for each publication in the given XML file" do
              expect { importer.call }.to change { Grant.count }.by 2
              expect(Grant.find_by(wos_agency_name: 'NSF',
                                   wos_identifier: 'ATMO-0803779',
                                   agency_name: 'National Science Foundation',
                                   identifier: '0803779')).not_to be_nil
              expect(Grant.find_by(wos_agency_name: 'NIH',
                                   wos_identifier: 'NIH-346346',
                                   agency_name: nil,
                                   identifier: nil)).not_to be_nil
            end
            it "creates new associations between the new grants and new publications" do
              expect { importer.call }.to change { ResearchFund.count }.by 2

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')
              new_grant1 = Grant.find_by(wos_agency_name: 'NSF',
                                         wos_identifier: 'ATMO-0803779')
              new_grant2 = Grant.find_by(wos_agency_name: 'NIH',
                                         wos_identifier: 'NIH-346346')

              expect(ResearchFund.find_by(publication: new_pub1, grant: new_grant1)).not_to be_nil
              expect(ResearchFund.find_by(publication: new_pub2, grant: new_grant2)).not_to be_nil
            end
            it "creates a new publication import record for each publication in the given XML file" do
              expect { importer.call }.to change { PublicationImport.count }.by 2

              new_import1 = PublicationImport.find_by(source_identifier: 'WOS:000323531400013')
              new_import2 = PublicationImport.find_by(source_identifier: 'WOS:000323531400014')
              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(new_import1.source).to eq 'Web of Science'
              expect(new_import1.publication).to eq new_pub1
              expect(new_import2.source).to eq 'Web of Science'
              expect(new_import2.publication).to eq new_pub2
            end
            it "creates a new publication record for each publication in the given XML file" do
              expect { importer.call }.to change { Publication.count }.by 2

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(new_pub1).not_to be_nil
              expect(new_pub2).not_to be_nil
            end
          end
          context "when existing grants have the same Web of Science agency and identifier" do
            let!(:grant1) { create :grant,
                                   wos_agency_name: 'NSF',
                                   wos_identifier: 'ATMO-0803779'}
            let!(:grant2) { create :grant,
                                   wos_agency_name: 'NIH',
                                   wos_identifier: 'NIH-346346'}
            it "does not create any new grants" do
              expect { importer.call }.not_to change { Grant.count }
            end
            it "creates new associations between the existing grants and new publications" do
              expect { importer.call }.to change { ResearchFund.count }.by 2

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(ResearchFund.find_by(publication: new_pub1, grant: grant1)).not_to be_nil
              expect(ResearchFund.find_by(publication: new_pub2, grant: grant2)).not_to be_nil
            end
            it "creates a new publication import record for each publication in the given XML file" do
              expect { importer.call }.to change { PublicationImport.count }.by 2

              new_import1 = PublicationImport.find_by(source_identifier: 'WOS:000323531400013')
              new_import2 = PublicationImport.find_by(source_identifier: 'WOS:000323531400014')
              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(new_import1.source).to eq 'Web of Science'
              expect(new_import1.publication).to eq new_pub1

              expect(new_import2.source).to eq 'Web of Science'
              expect(new_import2.publication).to eq new_pub2
            end
            it "creates a new publication record for each publication in the given XML file" do
              expect { importer.call }.to change { Publication.count }.by 2

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(new_pub1.publication_type).to eq 'Journal Article'
              expect(new_pub1.doi).to eq 'https://doi.org/10.15288/jsad.2013.74.765'
              expect(new_pub1.issn).to eq '1937-1888'
              expect(new_pub1.abstract).to eq 'Objective: Studies show that emerging adults who do not obtain postsecondary education are at greater risk for developing alcohol use disorders later in life relative to their college-attending peers.'
              expect(new_pub1.journal_title).to eq 'JOURNAL OF STUDIES ON ALCOHOL AND DRUGS'
              expect(new_pub1.issue).to eq '5'
              expect(new_pub1.volume).to eq '74'
              expect(new_pub1.page_range).to eq '765-769'
              expect(new_pub1.publisher).to eq 'ALCOHOL RES DOCUMENTATION INC CENT ALCOHOL STUD RUTGERS UNIV'
              expect(new_pub1.published_on).to eq Date.new(2013, 9, 1)
              expect(new_pub1.status).to eq 'Published'

              expect(new_pub2.publication_type).to eq 'Journal Article'
              expect(new_pub2.doi).to be nil
              expect(new_pub2.issn).to eq '3964-0326'
              expect(new_pub2.abstract).to eq 'A summary of the research and findings'
              expect(new_pub2.journal_title).to eq 'Another Academic Journal'
              expect(new_pub2.issue).to eq '8'
              expect(new_pub2.volume).to eq '20'
              expect(new_pub2.page_range).to eq '201-209'
              expect(new_pub2.publisher).to eq 'Another Publisher'
              expect(new_pub2.published_on).to eq Date.new(2016, 8, 2)
              expect(new_pub2.status).to eq 'Published'
            end
            it "creates new authorships for every user referenced in the given XML file" do
              expect { importer.call }.to change { Authorship.count }.by 3

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              new_auth1 = Authorship.find_by(publication: new_pub1, user: u1, confirmed: true)
              new_auth2 = Authorship.find_by(publication: new_pub1, user: u2, confirmed: false)
              new_auth3 = Authorship.find_by(publication: new_pub2, user: u3, confirmed: true)

              expect(new_auth1.author_number).to eq 1
              expect(new_auth2.author_number).to eq 2
              expect(new_auth3.author_number).to eq 1
            end
            it "creates new contributors for every author in the given XML file" do
              expect { importer.call }.to change { Contributor.count }.by 4

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(Contributor.find_by(publication: new_pub1,
                                         first_name: 'Jennifer',
                                         middle_name: 'A',
                                         last_name: 'Testauthor',
                                         position: 1)).not_to be_nil
              expect(Contributor.find_by(publication: new_pub1,
                                         first_name: 'Arthur',
                                         middle_name: nil,
                                         last_name: 'Author',
                                         position: 2)).not_to be_nil
              expect(Contributor.find_by(publication: new_pub2,
                                         first_name: 'P',
                                         middle_name: nil,
                                         last_name: 'Testerson',
                                         position: 1)).not_to be_nil
              expect(Contributor.find_by(publication: new_pub2,
                                         first_name: 'Elizabeth',
                                         middle_name: 'Mary',
                                         last_name: 'Testresearcher',
                                         position: 2)).not_to be_nil
            end
          end
          context "when existing grants match the Web of Science agency and identifier" do
            let!(:grant1) { create :grant,
                                   agency_name: 'National Science Foundation',
                                   identifier: '0803779'}
            let!(:grant2) { create :grant,
                                   wos_agency_name: 'NIH',
                                   wos_identifier: 'NIH-346346'}
            it "does not create any new grants" do
              expect { importer.call }.not_to change { Grant.count }
            end
            it "creates new associations between the existing grants and new publications" do
              expect { importer.call }.to change { ResearchFund.count }.by 2

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(ResearchFund.find_by(publication: new_pub1, grant: grant1)).not_to be_nil
              expect(ResearchFund.find_by(publication: new_pub2, grant: grant2)).not_to be_nil
            end
            it "creates a new publication import record for each publication in the given XML file" do
              expect { importer.call }.to change { PublicationImport.count }.by 2

              new_import1 = PublicationImport.find_by(source_identifier: 'WOS:000323531400013')
              new_import2 = PublicationImport.find_by(source_identifier: 'WOS:000323531400014')
              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(new_import1.source).to eq 'Web of Science'
              expect(new_import1.publication).to eq new_pub1

              expect(new_import2.source).to eq 'Web of Science'
              expect(new_import2.publication).to eq new_pub2
            end
            it "creates a new publication record for each publication in the given XML file" do
              expect { importer.call }.to change { Publication.count }.by 2

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(new_pub1.publication_type).to eq 'Journal Article'
              expect(new_pub1.doi).to eq 'https://doi.org/10.15288/jsad.2013.74.765'
              expect(new_pub1.issn).to eq '1937-1888'
              expect(new_pub1.abstract).to eq 'Objective: Studies show that emerging adults who do not obtain postsecondary education are at greater risk for developing alcohol use disorders later in life relative to their college-attending peers.'
              expect(new_pub1.journal_title).to eq 'JOURNAL OF STUDIES ON ALCOHOL AND DRUGS'
              expect(new_pub1.issue).to eq '5'
              expect(new_pub1.volume).to eq '74'
              expect(new_pub1.page_range).to eq '765-769'
              expect(new_pub1.publisher).to eq 'ALCOHOL RES DOCUMENTATION INC CENT ALCOHOL STUD RUTGERS UNIV'
              expect(new_pub1.published_on).to eq Date.new(2013, 9, 1)
              expect(new_pub1.status).to eq 'Published'

              expect(new_pub2.publication_type).to eq 'Journal Article'
              expect(new_pub2.doi).to be nil
              expect(new_pub2.issn).to eq '3964-0326'
              expect(new_pub2.abstract).to eq 'A summary of the research and findings'
              expect(new_pub2.journal_title).to eq 'Another Academic Journal'
              expect(new_pub2.issue).to eq '8'
              expect(new_pub2.volume).to eq '20'
              expect(new_pub2.page_range).to eq '201-209'
              expect(new_pub2.publisher).to eq 'Another Publisher'
              expect(new_pub2.published_on).to eq Date.new(2016, 8, 2)
              expect(new_pub2.status).to eq 'Published'
            end
            it "creates new authorships for every user referenced in the given XML file" do
              expect { importer.call }.to change { Authorship.count }.by 3

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              new_auth1 = Authorship.find_by(publication: new_pub1, user: u1, confirmed: true)
              new_auth2 = Authorship.find_by(publication: new_pub1, user: u2, confirmed: false)
              new_auth3 = Authorship.find_by(publication: new_pub2, user: u3, confirmed: true)

              expect(new_auth1.author_number).to eq 1
              expect(new_auth2.author_number).to eq 2
              expect(new_auth3.author_number).to eq 1
            end
            it "creates new contributors for every author in the given XML file" do
              expect { importer.call }.to change { Contributor.count }.by 4

              new_pub1 = Publication.find_by(title: 'Web of Science Test Publication')
              new_pub2 = Publication.find_by(title: 'Another Publication')

              expect(Contributor.find_by(publication: new_pub1,
                                          first_name: 'Jennifer',
                                          middle_name: 'A',
                                          last_name: 'Testauthor',
                                          position: 1)).not_to be_nil
              expect(Contributor.find_by(publication: new_pub1,
                                          first_name: 'Arthur',
                                          middle_name: nil,
                                          last_name: 'Author',
                                          position: 2)).not_to be_nil
              expect(Contributor.find_by(publication: new_pub2,
                                          first_name: 'P',
                                          middle_name: nil,
                                          last_name: 'Testerson',
                                          position: 1)).not_to be_nil
              expect(Contributor.find_by(publication: new_pub2,
                                          first_name: 'Elizabeth',
                                          middle_name: 'Mary',
                                          last_name: 'Testresearcher',
                                          position: 2)).not_to be_nil
            end
          end
        end
      end
      context "when existing publications match the data" do
        let!(:pub1) { create :publication, doi: 'https://doi.org/10.15288/jsad.2013.74.765' }
        let!(:pub2) { create :publication, title: 'Another Publication', published_on: Date.new(2016, 8, 1) }
        context "when no existing grants match the data" do
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "creates new grants where agency name and ID information are available" do
            expect { importer.call }.to change { Grant.count }.by 2
            expect(Grant.find_by(wos_agency_name: 'NSF',
                                 wos_identifier: 'ATMO-0803779',
                                 agency_name: 'National Science Foundation',
                                 identifier: '0803779')).not_to be_nil
            expect(Grant.find_by(wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346',
                                 agency_name: nil,
                                 identifier: nil)).not_to be_nil
          end
          it "creates new research fund records to associate the grants with the publications" do
            expect { importer.call }.to change { ResearchFund.count }.by 2
            new_grant1 = Grant.find_by(wos_agency_name: 'NSF',
                                      wos_identifier: 'ATMO-0803779')
            new_grant2 = Grant.find_by(wos_agency_name: 'NIH',
                                       wos_identifier: 'NIH-346346')
            expect(pub1.grants).to eq [new_grant1]
            expect(pub2.grants).to eq [new_grant2]
          end
        end
        context "when existing grants have the same Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 wos_agency_name: 'NSF',
                                 wos_identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}

          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants match the Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: '0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "creates new research fund records to associate the matching grants with the publications" do
            expect { importer.call }.to change { ResearchFund.count }.by 1
            expect(pub1.grants).to eq [grant1]
          end
        end
      end
      context "when the publications have already been imported" do
        before do
          create :publication_import, source: 'Web of Science', source_identifier: 'WOS:000323531400013'
          create :publication_import, source: 'Web of Science', source_identifier: 'WOS:000323531400014'
        end
        context "when no existing grants match the data" do
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants have the same Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 wos_agency_name: 'NSF',
                                 wos_identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants match the Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: '0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
      end
    end

    context "when given an XML file of publication data from Web of Science with non-Penn State Journal Articles" do
      let(:dirname) { Rails.root.join('spec', 'fixtures', 'wos_non_psu_articles') }
      context "when no existing publications match the data" do
        context "when no existing grants match the data" do
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants have the same Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 wos_agency_name: 'NSF',
                                 wos_identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants match the Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: '0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
      end
      context "when existing publications match the data" do
        let!(:pub1) { create :publication, doi: 'https://doi.org/10.15288/jsad.2013.74.765' }
        let!(:pub2) { create :publication, title: 'Another Publication', published_on: Date.new(2013, 9, 1) }
        context "when no existing grants match the data" do
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants have the same Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 wos_agency_name: 'NSF',
                                 wos_identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants match the Web of Science agency and identifier" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: '0803779'}
          let!(:grant2) { create :grant,
                                 wos_agency_name: 'NIH',
                                 wos_identifier: 'NIH-346346'}
          it "does not create any new grants" do
            expect { importer.call }.not_to change { Grant.count }
          end
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "does not create any new associations between grants and publications" do
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
      end
    end
  end

  context "when given an XML file of publication data from Web of Science with Penn State non-Journal Articles" do
    let(:dirname) { Rails.root.join('spec', 'fixtures', 'wos_psu_non_articles') }
    context "when no existing publications match the data" do
      context "when no existing grants match the data" do
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants have the same Web of Science agency and identifier" do
        let!(:grant1) { create :grant,
                               wos_agency_name: 'NSF',
                               wos_identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               wos_agency_name: 'NIH',
                               wos_identifier: 'NIH-346346'}
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants match the Web of Science agency and identifier" do
        let!(:grant1) { create :grant,
                               agency_name: 'National Science Foundation',
                               identifier: '0803779'}
        let!(:grant2) { create :grant,
                               wos_agency_name: 'NIH',
                               wos_identifier: 'NIH-346346'}
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
    context "when existing publications match the data" do
      let!(:pub1) { create :publication, doi: 'https://doi.org/10.15288/jsad.2013.74.765' }
      let!(:pub2) { create :publication, title: 'Another Publication', published_on: Date.new(2013, 9, 1) }
      context "when no existing grants match the data" do
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants have the same Web of Science agency and identifier" do
        let!(:grant1) { create :grant,
                               wos_agency_name: 'NSF',
                               wos_identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               wos_agency_name: 'NIH',
                               wos_identifier: 'NIH-346346'}
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
    context "when existing grants match the Web of Science agency and identifier" do
      let!(:grant1) { create :grant,
                             agency_name: 'National Science Foundation',
                             identifier: '0803779'}
      let!(:grant2) { create :grant,
                             wos_agency_name: 'NIH',
                             wos_identifier: 'NIH-346346'}
      it "does not create any new grants" do
        expect { importer.call }.not_to change { Grant.count }
      end
      it "does not create any new publications" do
        expect { importer.call }.not_to change { Publication.count }
      end
      it "does not create any new associations between grants and publications" do
        expect { importer.call }.not_to change { ResearchFund.count }
      end
    end
  end

  context "when given an XML file of publication data from Web of Science with non-Penn State non-Journal Articles" do
    let(:dirname) { Rails.root.join('spec', 'fixtures', 'wos_non_psu_non_articles') }
    context "when no existing publications match the data" do
      context "when no existing grants match the data" do
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants have the same Web of Science agency and identifier" do
        let!(:grant1) { create :grant,
                               wos_agency_name: 'NSF',
                               wos_identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               wos_agency_name: 'NIH',
                               wos_identifier: 'NIH-346346'}
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants match the Web of Science agency and identifier" do
        let!(:grant1) { create :grant,
                               agency_name: 'National Science Foundation',
                               identifier: '0803779'}
        let!(:grant2) { create :grant,
                               wos_agency_name: 'NIH',
                               wos_identifier: 'NIH-346346'}
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
    context "when existing publications match the data" do
      let!(:pub1) { create :publication, doi: 'https://doi.org/10.15288/jsad.2013.74.765' }
      let!(:pub2) { create :publication, title: 'Another Publication', published_on: Date.new(2013, 9, 1) }
      context "when no existing grants match the data" do
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants have the same Web of Science agency and identifier" do
        let!(:grant1) { create :grant,
                               wos_agency_name: 'NSF',
                               wos_identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               wos_agency_name: 'NIH',
                               wos_identifier: 'NIH-346346'}
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants match the Web of Science agency and identifier" do
        let!(:grant1) { create :grant,
                               agency_name: 'National Science Foundation',
                               identifier: '0803779'}
        let!(:grant2) { create :grant,
                               wos_agency_name: 'NIH',
                               wos_identifier: 'NIH-346346'}
        it "does not create any new grants" do
          expect { importer.call }.not_to change { Grant.count }
        end
        it "does not create any new publications" do
          expect { importer.call }.not_to change { Publication.count }
        end
        it "does not create any new associations between grants and publications" do
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
  end
end
