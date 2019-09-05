require 'component/component_spec_helper'

describe WebOfScienceFileImporter do
  let(:importer) { WebOfScienceFileImporter.new(filename: filename) }

  describe '#call' do
    context "when given an XML file of publication data from Web of Science with Penn State Journal Articles" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'wos_psu_articles.xml') }
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
          context "when existing grants match the data" do
            let!(:grant1) { create :grant,
                                   agency_name: 'National Science Foundation',
                                   identifier: 'ATMO-0803779'}
            let!(:grant2) { create :grant,
                                   agency_name: 'NIH',
                                   identifier: 'NIH-346346'}
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
            end
            it "creates new associations between the new grants and new publications" do
              expect { importer.call }.to change { ResearchFund.count }.by 2
            end
            it "creates a new publication import record for each publication in the given XML file" do
              expect { importer.call }.to change { PublicationImport.count }.by 2
            end
            it "creates a new publication record for each publication in the given XML file" do
              expect { importer.call }.to change { Publication.count }.by 2
            end
          end
          context "when existing grants match the data" do
            let!(:grant1) { create :grant,
                                   agency_name: 'National Science Foundation',
                                   identifier: 'ATMO-0803779'}
            let!(:grant2) { create :grant,
                                   agency_name: 'NIH',
                                   identifier: 'NIH-346346'}
            it "does not create any new grants" do
              expect { importer.call }.not_to change { Grant.count }
            end
            it "creates new associations between the existing grants and new publications" do
              expect { importer.call }.to change { ResearchFund.count }.by 2
            end
            it "creates a new publication import record for each publication in the given XML file" do
              expect { importer.call }.to change { PublicationImport.count }.by 2
            end
            it "creates a new publication record for each publication in the given XML file" do
              expect { importer.call }.to change { Publication.count }.by 2
            end
          end
        end
      end
      context "when existing publications match the data" do
        let!(:pub1) { create :publication, doi: 'https://doi.org/10.15288/jsad.2013.74.765' }
        let!(:pub2) { create :publication, title: 'Another Publication', published_on: Date.new(2013, 9, 1) }
        context "when no existing grants match the data" do
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "creates new grants where agency name and ID information are available" do
            expect { importer.call }.to change { Grant.count }.by 2
            expect(Grant.find_by(agency_name: 'National Science Foundation',
                                 identifier: 'ATMO-0803779')).not_to be_nil
            expect(Grant.find_by(agency_name: 'NIH',
                                 identifier: 'NIH-346346')).not_to be_nil
          end
          it "creates new research fund records to associate the grants with the publications" do
            expect { importer.call }.to change { ResearchFund.count }.by 2
            new_grant1 = Grant.find_by(agency_name: 'National Science Foundation',
                                      identifier: 'ATMO-0803779')
            new_grant2 = Grant.find_by(agency_name: 'NIH',
                                       identifier: 'NIH-346346')
            expect(pub1.grants).to eq [new_grant1]
            expect(pub2.grants).to eq [new_grant2]
          end
        end
        context "when existing grants match the data" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 agency_name: 'NIH',
                                 identifier: 'NIH-346346'}

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
        context "when existing grants match the data" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 agency_name: 'NIH',
                                 identifier: 'NIH-346346'}
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
      let(:filename) { Rails.root.join('spec', 'fixtures', 'wos_non_psu_articles.xml') }
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
        context "when existing grants match the data" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 agency_name: 'NIH',
                                 identifier: 'NIH-346346'}
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
        context "when existing grants match the data" do
          let!(:grant1) { create :grant,
                                 agency_name: 'National Science Foundation',
                                 identifier: 'ATMO-0803779'}
          let!(:grant2) { create :grant,
                                 agency_name: 'NIH',
                                 identifier: 'NIH-346346'}
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
    let(:filename) { Rails.root.join('spec', 'fixtures', 'wos_psu_non_articles.xml') }
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
      context "when existing grants match the data" do
        let!(:grant1) { create :grant,
                               agency_name: 'National Science Foundation',
                               identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               agency_name: 'NIH',
                               identifier: 'NIH-346346'}
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
      context "when existing grants match the data" do
        let!(:grant1) { create :grant,
                               agency_name: 'National Science Foundation',
                               identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               agency_name: 'NIH',
                               identifier: 'NIH-346346'}
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

  context "when given an XML file of publication data from Web of Science with non-Penn State non-Journal Articles" do
    let(:filename) { Rails.root.join('spec', 'fixtures', 'wos_non_psu_non_articles.xml') }
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
      context "when existing grants match the data" do
        let!(:grant1) { create :grant,
                               agency_name: 'National Science Foundation',
                               identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               agency_name: 'NIH',
                               identifier: 'NIH-346346'}
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
      context "when existing grants match the data" do
        let!(:grant1) { create :grant,
                               agency_name: 'National Science Foundation',
                               identifier: 'ATMO-0803779'}
        let!(:grant2) { create :grant,
                               agency_name: 'NIH',
                               identifier: 'NIH-346346'}
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
