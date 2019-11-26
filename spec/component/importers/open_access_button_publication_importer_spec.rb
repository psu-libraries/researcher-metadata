require 'component/component_spec_helper'

describe OpenAccessButtonPublicationImporter do
  let(:importer) { OpenAccessButtonPublicationImporter.new }

  let(:now) { Time.new(2019, 11, 13, 0, 0, 0) }
  before do
    allow(Time).to receive(:current).and_return(now)
  end

  describe '#call' do
    context "when an existing publication does not have a DOI" do
      let!(:pub) { create :publication, doi: nil}

      it "does not update the publication's open access URL" do
        importer.call
        expect(pub.reload.open_access_url).to be_nil
      end

      it "does not update the publication's Open Access Button check timestamp" do
        importer.call
        expect(pub.reload.open_access_button_last_checked_at).to be_nil
      end
    end

    context "when an existing publication has a blank DOI" do
      let!(:pub) { create :publication, doi: ''}

      it "does not update the publication's open access URL" do
        importer.call
        expect(pub.reload.open_access_url).to be_nil
      end

      it "does not update the publication's Open Access Button check timestamp" do
        importer.call
        expect(pub.reload.open_access_button_last_checked_at).to be_nil
      end
    end

    context "when an existing publication has a DOI that corresponds to an available article listed with Open Access Button" do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/pub/doi1',
                          open_access_button_last_checked_at: last_check }

      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=pub/doi1").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab1.json')))
      end
      context "when the publication was last checked in Open Access Button more than a month ago" do
        let(:last_check) { now - (32.days) }
        it "updates the publication with the URL to the open access content" do
          importer.call
          expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
        end

        it "updates Open Access Button check timestamp on the publication" do
          importer.call
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.call
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "does not update the publication's Open Access Button check timestamp" do
            importer.call
            expect(pub.reload.open_access_button_last_checked_at).to eq now - 32.days
          end
        end
      end
      context "when the publication has never been checked in Open Access Button" do
        let(:last_check) { nil }
        it "updates the publication with the URL to the open access content" do
          importer.call
          expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
        end

        it "updates Open Access Button check timestamp on the publication" do
          importer.call
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end
        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.call
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "does not update the publication's Open Access Button check timestamp" do
            importer.call
            expect(pub.reload.open_access_button_last_checked_at).to be_nil
          end
        end
      end
      context "when the publication was last checked in Open Access Button less than a month ago" do
        let(:last_check) { now - (30.days) }
        it "does not update the publication's open access URL" do
          importer.call
          expect(pub.reload.open_access_url).to be_nil
        end
  
        it "does not update the publication's Open Access Button check timestamp" do
          importer.call
          expect(pub.reload.open_access_button_last_checked_at).to eq now - 30.days
        end
      end
    end

    context "when an existing publication has a DOI that does not correspond to an available article listed with Open Access Button" do
      let!(:pub) { create :publication,
        doi: 'https://doi.org/pub/doi1',
        open_access_button_last_checked_at: last_check }

      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=pub/doi1").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab2.json')))
      end
      context "when the publication was last checked in Open Access Button more than a month ago" do
        let(:last_check) { now - (32.days) }
        it "does not update the publication's open access URL" do
          importer.call
          expect(pub.reload.open_access_url).to be_nil
        end

        it "updates Open Access Button check timestamp on the publication" do
          importer.call
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.call
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "does not update the publication's Open Access Button check timestamp" do
            importer.call
            expect(pub.reload.open_access_button_last_checked_at).to eq now - 32.days
          end
        end
      end
      context "when the publication has never been checked in Open Access Button" do
        let(:last_check) { nil }

        it "does not update the publication's open access URL" do
          importer.call
          expect(pub.reload.open_access_url).to be_nil
        end

        it "updates Open Access Button check timestamp on the publication" do
          importer.call
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.call
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "does not update the publication's Open Access Button check timestamp" do
            importer.call
            expect(pub.reload.open_access_button_last_checked_at).to be_nil
          end
        end
      end
      context "when the publication was last checked in Open Access Button less than a month ago" do
        let(:last_check) { now - (30.days) }
        it "does not update the publication's open access URL" do
          importer.call
          expect(pub.reload.open_access_url).to be_nil
        end
  
        it "does not update the publication's Open Access Button check timestamp" do
          importer.call
          expect(pub.reload.open_access_button_last_checked_at).to eq now - 30.days
        end
      end
    end
  end

  context "when an existing publication has a DOI that corresponds to more than one available article listed with Open Access Button" do
    let!(:pub) { create :publication, doi: 'https://doi.org/pub/doi1' }

    before do
      allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=pub/doi1").
      and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab3.json')))
    end

    it "updates the publication with the first URL to the open access content" do
      importer.call
      expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
    end

    it "updates Open Access Button check timestamp on the publication" do
      importer.call
      expect(pub.reload.open_access_button_last_checked_at).to eq now
    end
  end

  context "when an existing publication has a DOI that corresponds to content listed with Open Access Button that is not an article" do
    let!(:pub) { create :publication, doi: 'https://doi.org/pub/doi1' }

    before do
      allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=pub/doi1").
      and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab4.json')))
    end

    it "does not update the publication's open access URL" do
      importer.call
      expect(pub.reload.open_access_url).to be_nil
    end

    it "updates Open Access Button check timestamp on the publication" do
      importer.call
      expect(pub.reload.open_access_button_last_checked_at).to eq now
    end
  end
end
