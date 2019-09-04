require 'component/component_spec_helper'

describe WebOfScienceFileImporter do
  let(:importer) { WebOfScienceFileImporter.new(filename: filename) }

  describe '#call' do
    context "when given an XML file of publication data from Web of Science with Penn State Journal Articles" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'wos_psu_articles.xml') }
      context "when no existing publications match the data" do
        context "when no existing grants match the data" do
          it "does not create any new grants or publications" do
            expect { importer.call }.not_to change { Grant.count }
            expect { importer.call }.not_to change { Publication.count }
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants match the data" do
          before { create :grant,
                          agency_name: 'National Science Foundation',
                          identifier: 'ATMO-0803779'}
          it "does not create any new grants or publications" do
            expect { importer.call }.not_to change { Grant.count }
            expect { importer.call }.not_to change { Publication.count }
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
      end
      context "when existing publications match the data" do
        let!(:pub) { create :publication, doi: 'https://doi.org/10.15288/jsad.2013.74.765' }
        context "when no existing grants match the data for matching publications" do
          it "does not create any new publications" do
            expect { importer.call }.not_to change { Publication.count }
          end
          it "creates new grants where agency name and ID information are available" do
            expect { importer.call }.to change { Grant.count }.by 1
            expect(Grant.find_by(agency_name: 'National Science Foundation',
                                 identifier: 'ATMO-0803779')).not_to be_nil
          end
          it "creates new research fund records to associate the new grants with the publications" do
            expect { importer.call }.to change { ResearchFund.count }.by 1
            new_grant = Grant.find_by(agency_name: 'National Science Foundation',
                                      identifier: 'ATMO-0803779')
            expect(pub.grants).to eq [new_grant]
          end
        end
        context "when existing grants match the data for matching publications" do
          before { create :grant,
                          agency_name: 'National Science Foundation',
                          identifier: 'ATMO-0803779'}

          it "does not create any new grants or publications" do
            expect { importer.call }.not_to change { Grant.count }
            expect { importer.call }.not_to change { Publication.count }
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
      end
    end

    context "when given an XML file of publication data from Web of Science with non-Penn State Journal Articles" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'wos_non_psu_articles.xml') }
      context "when no existing publications match the data" do
        context "when no existing grants match the data" do
          it "does not create any new grants or publications" do
            expect { importer.call }.not_to change { Grant.count }
            expect { importer.call }.not_to change { Publication.count }
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants match the data" do
          it "does not create any new grants or publications" do
            expect { importer.call }.not_to change { Grant.count }
            expect { importer.call }.not_to change { Publication.count }
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
      end
      context "when existing publications match the data" do
        context "when no existing grants match the data for matching publications" do
          it "does not create any new grants or publications" do
            expect { importer.call }.not_to change { Grant.count }
            expect { importer.call }.not_to change { Publication.count }
            expect { importer.call }.not_to change { ResearchFund.count }
          end
        end
        context "when existing grants match the data for matching publications" do
          it "does not create any new grants or publications" do
            expect { importer.call }.not_to change { Grant.count }
            expect { importer.call }.not_to change { Publication.count }
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
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants match the data" do
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
    context "when existing publications match the data" do
      context "when no existing grants match the data for matching publications" do
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants match the data for matching publications" do
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
  end

  context "when given an XML file of publication data from Web of Science with non-Penn State non-Journal Articles" do
    let(:filename) { Rails.root.join('spec', 'fixtures', 'wos_non_psu_non_articles.xml') }
    context "when no existing publications match the data" do
      context "when no existing grants match the data" do
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants match the data" do
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
    context "when existing publications match the data" do
      context "when no existing grants match the data for matching publications" do
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
      context "when existing grants match the data for matching publications" do
        it "does not create any new grants or publications" do
          expect { importer.call }.not_to change { Grant.count }
          expect { importer.call }.not_to change { Publication.count }
          expect { importer.call }.not_to change { ResearchFund.count }
        end
      end
    end
  end
end
