require 'component/component_spec_helper'

describe ActivityInsightPublicationImporter do
  let(:importer) { ActivityInsightPublicationImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid publication data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_publications.csv') }

      context "when no publication records exist in the database" do
        it "creates a new publication import record for every row in the .csv file that represents a journal article" do
          expect { importer.call }.to change { PublicationImport.count }.by 3
        end

        it "creates a new publication record for every row in the .csv file that represents a journal article" do
          expect { importer.call }.to change { Publication.count }.by 3

          p1 = PublicationImport.find_by(source: 'Activity Insight',
                                         source_identifier: '107659829248').publication
          p2 = PublicationImport.find_by(source: 'Activity Insight',
                                         source_identifier: '107659765760').publication
          p3 = PublicationImport.find_by(source: 'Activity Insight',
                                         source_identifier: '137106827264').publication

          expect(p1.title).to eq 'Test Title One'
          expect(p1.publication_type).to eq 'Journal Article'
          expect(p1.publisher).to eq 'Test Publisher One'
          expect(p1.secondary_title).to eq '2015'
          expect(p1.status).to eq 'Accepted'
          expect(p1.volume).to eq '41'
          expect(p1.issue).to eq '6'
          expect(p1.edition).to eq '3'
          expect(p1.page_range).to eq '189-234'
          expect(p1.url).to eq 'url_1'
          expect(p1.issn).to eq 'ISSN1'
          expect(p1.abstract).to eq 'Test Abstract 1'
          expect(p1.authors_et_al).to eq true
          expect(p1.published_on).to eq Date.new(2015, 4, 1)
          expect(p1.visible).to eq false
          expect(p1.updated_by_user_at).to eq nil

          expect(p2.title).to eq 'Test Title Two'
          expect(p2.publication_type).to eq 'Professional Journal Article'
          expect(p2.publisher).to eq 'Test Publisher Two'
          expect(p2.secondary_title).to eq nil
          expect(p2.status).to eq 'Accepted'
          expect(p2.volume).to eq '12'
          expect(p2.issue).to eq '4'
          expect(p2.edition).to eq '1'
          expect(p2.page_range).to eq '20-30'
          expect(p2.url).to eq nil
          expect(p2.issn).to eq nil
          expect(p2.abstract).to eq nil
          expect(p2.authors_et_al).to eq false
          expect(p2.published_on).to eq nil
          expect(p2.visible).to eq false
          expect(p2.updated_by_user_at).to eq nil

          expect(p3.title).to eq 'Test Title Four'
          expect(p3.publication_type).to eq 'Academic Journal Article'
          expect(p3.publisher).to eq 'Test Publisher Three'
          expect(p3.secondary_title).to eq nil
          expect(p3.status).to eq 'Accepted'
          expect(p3.volume).to eq nil
          expect(p3.issue).to eq nil
          expect(p3.edition).to eq nil
          expect(p3.page_range).to eq nil
          expect(p3.url).to eq 'url_2'
          expect(p3.issn).to eq nil
          expect(p3.abstract).to eq 'Test Abstract 2'
          expect(p3.authors_et_al).to eq false
          expect(p3.published_on).to eq Date.new(2017, 3, 1)
          expect(p3.visible).to eq false
          expect(p3.updated_by_user_at).to eq nil
        end
      end
    end
  end
end
