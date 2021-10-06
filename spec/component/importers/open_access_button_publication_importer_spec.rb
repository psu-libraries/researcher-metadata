require 'component/component_spec_helper'

describe OpenAccessButtonPublicationImporter do
  let(:importer) { OpenAccessButtonPublicationImporter.new }

  let(:now) { Time.new(2019, 11, 13, 0, 0, 0) }
  before do
    allow(Time).to receive(:current).and_return(now)
  end

  describe '#import_all' do
    context "when an existing publication does not have a DOI" do
      let!(:pub) { create :publication, doi: nil}

      it "does not update the publication's open access URL" do
        importer.import_all
        expect(pub.reload.open_access_url).to be_nil
      end

      it "does not update the publication's Open Access Button check timestamp" do
        importer.import_all
        expect(pub.reload.open_access_button_last_checked_at).to be_nil
      end
    end

    context "when an existing publication has a blank DOI" do
      let!(:pub) { create :publication, doi: ''}

      it "does not update the publication's open access URL" do
        importer.import_all
        expect(pub.reload.open_access_url).to be_nil
      end

      it "does not update the publication's Open Access Button check timestamp" do
        importer.import_all
        expect(pub.reload.open_access_button_last_checked_at).to be_nil
      end
    end

    context "when an existing publication's DOI does not return usable data" do
      let!(:pub) { create :publication, doi: "https://doi.org/10.000/nodata" }
      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=10.000/nodata").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab5.json')))
      end

      it "does not raise an error" do
        expect { importer.import_all }.not_to raise_error
      end
    end

    context "when an existing publication has a DOI that corresponds to an available article listed with Open Access Button" do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.000/doi1',
                          open_access_button_last_checked_at: last_check }

      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=10.000/doi1").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab1.json')))
      end
      context "when the publication was last checked in Open Access Button more than a month ago" do
        let(:last_check) { now - (32.days) }
        context "when the publication's open access URL is nil" do
          it "updates the publication with the URL to the open access content" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication's open access URL is blank" do
          before { pub.update_attribute(:open_access_url, "") }

          it "updates the publication with the URL to the open access content" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "updates the publication with the URL to the open access content" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
          end
    
          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end
      end
      context "when the publication has never been checked in Open Access Button" do
        let(:last_check) { nil }
        it "updates the publication with the URL to the open access content" do
          importer.import_all
          expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
        end

        it "updates Open Access Button check timestamp on the publication" do
          importer.import_all
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end
        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "updates the publication with the URL to the open access content" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
          end
    
          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end
      end
      context "when the publication was last checked in Open Access Button less than a month ago" do
        let(:last_check) { now - (30.days) }
        it "updates the publication with the URL to the open access content" do
          importer.import_all
          expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
        end
  
        it "updates Open Access Button check timestamp on the publication" do
          importer.import_all
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end
      end
    end

    context "when an existing publication has a DOI that does not correspond to an available article listed with Open Access Button" do
      let!(:pub) { create :publication,
        doi: 'https://doi.org/10.000/doi1',
        open_access_button_last_checked_at: last_check }

      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=10.000/doi1").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab2.json')))
      end
      context "when the publication was last checked in Open Access Button more than a month ago" do
        let(:last_check) { now - (32.days) }
        context "when the publication's open access URL is nil" do
          it "does not update the publication's open access URL" do
            importer.import_all
            expect(pub.reload.open_access_url).to be_nil
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication's open access URL is blank" do
          before { pub.update_attribute(:open_access_url, "") }

          it "does not update the publication's open access URL" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq ""
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end
      end
      context "when the publication has never been checked in Open Access Button" do
        let(:last_check) { nil }

        context "when the publication's open access URL is nil" do
          it "does not update the publication's open access URL" do
            importer.import_all
            expect(pub.reload.open_access_url).to be_nil
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication's open access URL is blank" do
          before { pub.update_attribute(:open_access_url, "") }

          it "does not update the publication's open access URL" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq ""
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.import_all
            expect(pub.reload.open_access_url).to eq "existing_url"
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end
      end
      context "when the publication was last checked in Open Access Button less than a month ago" do
        let(:last_check) { now - (30.days) }
        it "does not update the publication's open access URL" do
          importer.import_all
          expect(pub.reload.open_access_url).to be_nil
        end
  
        it "updates Open Access Button check timestamp on the publication" do
          importer.import_all
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end
      end
    end
  end

  describe '#import_new' do
    context "when an existing publication does not have a DOI" do
      let!(:pub) { create :publication, doi: nil}

      it "does not update the publication's open access URL" do
        importer.import_new
        expect(pub.reload.open_access_url).to be_nil
      end

      it "does not update the publication's Open Access Button check timestamp" do
        importer.import_new
        expect(pub.reload.open_access_button_last_checked_at).to be_nil
      end
    end

    context "when an existing publication has a blank DOI" do
      let!(:pub) { create :publication, doi: ''}

      it "does not update the publication's open access URL" do
        importer.import_new
        expect(pub.reload.open_access_url).to be_nil
      end

      it "does not update the publication's Open Access Button check timestamp" do
        importer.import_new
        expect(pub.reload.open_access_button_last_checked_at).to be_nil
      end
    end

    context "when an existing publication's DOI does not return usable data" do
      let!(:pub) { create :publication, doi: "https://doi.org/10.000/nodata" }
      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=10.000/nodata").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab5.json')))
      end

      it "does not raise an error" do
        expect { importer.import_new }.not_to raise_error
      end
    end

    context "when an existing publication has a DOI that corresponds to an available article listed with Open Access Button" do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.000/doi1',
                          open_access_button_last_checked_at: last_check }

      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=10.000/doi1").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab1.json')))
      end
      context "when the publication has been checked in Open Access Button before" do
        let(:last_check) { Time.new(2021, 1, 1, 0, 0, 0) }
        context "when the publication's open access URL is nil" do
          it "does not update the publication with the URL to the open access content" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq nil
          end

          it "does not update the Open Access Button check timestamp on the publication" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
          end
        end

        context "when the publication's open access URL is blank" do
          before { pub.update_attribute(:open_access_url, "") }

          it "does not update the publication with the URL to the open access content" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq ""
          end

          it "does not update the Open Access Button check timestamp on the publication" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
          end
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "does not update the publication's Open Access Button check timestamp" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
          end
        end
      end
      context "when the publication has never been checked in Open Access Button" do
        let(:last_check) { nil }
        it "updates the publication with the URL to the open access content" do
          importer.import_new
          expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
        end

        it "updates Open Access Button check timestamp on the publication" do
          importer.import_new
          expect(pub.reload.open_access_button_last_checked_at).to eq now
        end
        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "updates the publication with the URL to the open access content" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq "http://openaccessexample.org/publications/pub1.pdf"
          end
    
          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end
      end
      context "when the publication has been checked in Open Access Button before" do
        let(:last_check) { Time.new(2021, 1, 1, 0, 0, 0) }
        it "does not update the publication with the URL to the open access content" do
          importer.import_new
          expect(pub.reload.open_access_url).to eq nil
        end
  
        it "does not update the Open Access Button check timestamp on the publication" do
          importer.import_new
          expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
        end
      end
    end

    context "when an existing publication has a DOI that does not correspond to an available article listed with Open Access Button" do
      let!(:pub) { create :publication,
        doi: 'https://doi.org/10.000/doi1',
        open_access_button_last_checked_at: last_check }

      before do
        allow(HTTParty).to receive(:get).with("https://api.openaccessbutton.org/find?id=10.000/doi1").
        and_return(File.read(Rails.root.join('spec', 'fixtures', 'oab2.json')))
      end
      context "when the publication has been checked in Open Access Button before" do
        let(:last_check) { Time.new(2021, 1, 1, 0, 0, 0) }
        context "when the publication's open access URL is nil" do
          it "does not update the publication's open access URL" do
            importer.import_new
            expect(pub.reload.open_access_url).to be_nil
          end

          it "does not update the Open Access Button check timestamp on the publication" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
          end
        end

        context "when the publication's open access URL is blank" do
          before { pub.update_attribute(:open_access_url, "") }

          it "does not update the publication's open access URL" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq ""
          end

          it "does not update the Open Access Button check timestamp on the publication" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
          end
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "does not update the publication's Open Access Button check timestamp" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
          end
        end
      end
      context "when the publication has never been checked in Open Access Button" do
        let(:last_check) { nil }

        context "when the publication's open access URL is nil" do
          it "does not update the publication's open access URL" do
            importer.import_new
            expect(pub.reload.open_access_url).to be_nil
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication's open access URL is blank" do
          before { pub.update_attribute(:open_access_url, "") }

          it "does not update the publication's open access URL" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq ""
          end

          it "updates Open Access Button check timestamp on the publication" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end

        context "when the publication already has an open access URL" do
          before { pub.update_attribute(:open_access_url, "existing_url") }

          it "does not update the publication's open access URL" do
            importer.import_new
            expect(pub.reload.open_access_url).to eq "existing_url"
          end
    
          it "updates Open Access Button check timestamp on the publication" do
            importer.import_all
            expect(pub.reload.open_access_button_last_checked_at).to eq now
          end
        end
      end
      context "when the publication has been checked in Open Access Button before" do
        let(:last_check) { Time.new(2021, 1, 1, 0, 0, 0) }
        it "does not update the publication's open access URL" do
          importer.import_new
          expect(pub.reload.open_access_url).to be_nil
        end
  
        it "does not update the Open Access Button check timestamp on the publication" do
          importer.import_new
          expect(pub.reload.open_access_button_last_checked_at).to eq Time.new(2021, 1, 1, 0, 0, 0)
        end
      end
    end
  end
end
