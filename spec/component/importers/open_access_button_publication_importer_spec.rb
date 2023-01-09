# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAccessButtonPublicationImporter do
  let(:importer) { described_class.new }

  describe '#import_all' do
    context 'when an existing publication does not have a DOI' do
      # Tests that the " and ' characters are stripped from title when querying OAB title endpoint
      let!(:pub) { create(:publication, doi: nil, title: "Stable \"characteristic\" evolution of generic three-dimensional single-black-hole spacetimes'") }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?title=Stable+characteristic+evolution+of+generic+three-dimensional+single-black-hole+spacetimes')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab3.json').read)
      end

      it 'creates a new open access location for the publication' do
        expect { importer.import_new }.to change { pub.open_access_locations.count }.by 1
      end

      it 'updates Open Access Button check timestamp on the publication' do
        importer.import_new
        expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
      end

      it 'updates the publication DOI' do
        importer.import_new
        expect(pub.reload.doi).to eq 'https://doi.org/10.1103/PhysRevLett.80.3915'
      end
    end

    context 'when an existing publication has a blank DOI' do
      let!(:pub) { create(:publication, doi: '', title: 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes') }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?title=Stable+characteristic+evolution+of+generic+three-dimensional+single-black-hole+spacetimes')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab3.json').read)
      end

      it 'creates a new open access location for the publication' do
        expect { importer.import_new }.to change { pub.open_access_locations.count }.by 1
      end

      it 'updates Open Access Button check timestamp on the publication' do
        importer.import_new
        expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
      end

      it 'updates the publication DOI' do
        importer.import_new
        expect(pub.reload.doi).to eq 'https://doi.org/10.1103/PhysRevLett.80.3915'
      end
    end

    context "when an existing publication's DOI does not return usable data" do
      let!(:pub) { create(:publication, doi: 'https://doi.org/10.000/nodata') }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.000%2Fnodata')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab5.json').read)
      end

      it 'does not raise an error' do
        expect { importer.import_all }.not_to raise_error
      end
    end

    context 'when an existing publication has a DOI that corresponds to an available article listed with Open Access Button' do
      let!(:pub) { create(:publication,
                          doi: 'https://doi.org/10.000/doi1') }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.000%2Fdoi1')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab1.json').read)
      end

      context 'when the publication has no open access locations' do
        it 'creates a new open access location for the publication' do
          expect { importer.import_all }.to change { pub.open_access_locations.count }.by 1
        end

        it 'assigns the metadata from Open Access Button to the new open access location' do
          importer.import_all
          oal = pub.open_access_locations.find_by(source: Source::OPEN_ACCESS_BUTTON)
          expect(oal.url).to eq 'http://openaccessexample.org/publications/pub1.pdf'
        end

        it 'updates Open Access Button check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end
      end

      context 'when the publication already has an open access location from Open Access Button' do
        let!(:oal) { create(:open_access_location,
                            publication: pub,
                            url: 'existing_url',
                            source: Source::OPEN_ACCESS_BUTTON)}

        it 'does not create any new open access locations' do
          expect { importer.import_all }.not_to change(OpenAccessLocation, :count)
        end

        it 'updates the existing open access location with the URL to the open access content' do
          importer.import_all
          expect(oal.reload.url).to eq 'http://openaccessexample.org/publications/pub1.pdf'
        end

        it 'updates Open Access Button check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end
      end
    end

    context 'when an existing publication has a DOI that does not correspond to an available article listed with Open Access Button' do
      let!(:pub) { create(:publication,
                          doi: 'https://doi.org/10.000/doi1') }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.000%2Fdoi1')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab2.json').read)
      end

      context 'when the publication has no open access locations' do
        it 'does not create any new open access locations' do
          expect { importer.import_all }.not_to change(OpenAccessLocation, :count)
        end

        it 'updates Open Access Button check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end
      end

      context 'when the publication already has an open access location' do
        let!(:oal) { create(:open_access_location,
                            publication: pub,
                            url: 'existing_url',
                            source: Source::OPEN_ACCESS_BUTTON)}

        it 'removes the existing open access location' do
          expect { importer.import_all }.to change(OpenAccessLocation, :count).by -1
          expect { oal.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'updates Open Access Button check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end
      end
    end

    context 'when an error is raised' do
      let!(:pub) { create(:publication, doi: 'https://doi.org/10.000/nodata') }

      before do
        allow(CGI).to receive(:escape).and_raise(RuntimeError)
        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error' do
        importer.import_all

        expect(ImporterErrorLog)
          .to have_received(:log_error)
          .with(
            importer_class: described_class,
            error: an_instance_of(RuntimeError),
            metadata: {
              publication_id: pub.id,
              publication_doi_url_path: pub.doi_url_path,
              oab_json: ''
            }
          )
      end

      it 'continues with the import' do
        create(:publication, doi: 'https://doi.org/10.000/nodata')
        importer.import_all
        expect(ImporterErrorLog).to have_received(:log_error).twice
      end
    end

    context 'when the API request times out too many times' do
      let!(:pub) { create(:publication, doi: 'https://doi.org/10.000/nodata') }

      before do
        allow(HTTParty).to receive(:get).and_raise(Net::ReadTimeout)
        allow(ImporterErrorLog).to receive(:log_error)
      end

      it 'logs the error' do
        importer.import_all

        expect(ImporterErrorLog)
          .to have_received(:log_error)
          .with(
            importer_class: described_class,
            error: an_instance_of(Net::ReadTimeout),
            metadata: {
              publication_id: pub.id,
              publication_doi_url_path: pub.doi_url_path,
              oab_json: ''
            }
          )
      end

      it 'continues with the import' do
        create(:publication, doi: 'https://doi.org/10.000/nodata')
        importer.import_all
        expect(ImporterErrorLog).to have_received(:log_error).twice
      end
    end
  end

  describe '#import_new' do
    context 'when an existing publication does not have a DOI' do
      let!(:pub) { create(:publication, doi: nil, title: 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes') }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?title=Stable+characteristic+evolution+of+generic+three-dimensional+single-black-hole+spacetimes')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab3.json').read)
      end

      it 'creates a new open access location for the publication' do
        expect { importer.import_new }.to change { pub.open_access_locations.count }.by 1
      end

      it 'updates Open Access Button check timestamp on the publication' do
        importer.import_new
        expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
      end
    end

    context 'when an existing publication has a blank DOI' do
      let!(:pub) { create(:publication, doi: '', title: 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes') }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?title=Stable+characteristic+evolution+of+generic+three-dimensional+single-black-hole+spacetimes')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab3.json').read)
      end

      it 'creates a new open access location for the publication' do
        expect { importer.import_new }.to change { pub.open_access_locations.count }.by 1
      end

      it 'updates Open Access Button check timestamp on the publication' do
        importer.import_new
        expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
      end
    end

    context "when an existing publication's DOI does not return usable data" do
      let!(:pub) { create(:publication, doi: 'https://doi.org/10.000/nodata') }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.000%2Fnodata')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab5.json').read)
      end

      it 'does not raise an error' do
        expect { importer.import_new }.not_to raise_error
      end
    end

    context 'when an existing publication has a DOI that corresponds to an available article listed with Open Access Button' do
      let!(:pub) { create(:publication,
                          doi: 'https://doi.org/10.000/doi1',
                          open_access_button_last_checked_at: last_check) }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.000%2Fdoi1')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab1.json').read)
      end

      context 'when the publication has been checked in Open Access Button before' do
        let(:last_check) { Time.zone.yesterday }

        context 'when the publication has no open access locations' do
          it 'does not create any open access locations for the publication' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'does not update the Open Access Button check timestamp on the publication' do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.zone.yesterday
          end
        end

        context 'when the publication already has an open access location' do
          let!(:oal) { create(:open_access_location,
                              publication: pub,
                              url: 'existing_url',
                              source: Source::OPEN_ACCESS_BUTTON)}

          it 'does not create any new open access locations' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'does not update the URL for the existing open access location' do
            importer.import_new
            expect(oal.reload.url).to eq 'existing_url'
          end

          it "does not update the publication's Open Access Button check timestamp" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.zone.yesterday
          end
        end
      end

      context 'when the publication has never been checked in Open Access Button' do
        let(:last_check) { nil }

        it 'creates a new open access location for the publication' do
          expect { importer.import_new }.to change { pub.open_access_locations.count }.by 1
        end

        it 'assigns the metadata from Open Access Button to the new open access location' do
          importer.import_new
          oal = pub.open_access_locations.find_by(source: Source::OPEN_ACCESS_BUTTON)
          expect(oal.url).to eq 'http://openaccessexample.org/publications/pub1.pdf'
        end

        it 'updates Open Access Button check timestamp on the publication' do
          importer.import_new
          expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end
      end
    end

    context 'when an existing publication has a DOI that does not correspond to an available article listed with Open Access Button' do
      let!(:pub) { create(:publication,
                          doi: 'https://doi.org/10.000/doi1',
                          open_access_button_last_checked_at: last_check) }

      before do
        allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.000%2Fdoi1')
          .and_return(Rails.root.join('spec', 'fixtures', 'oab2.json').read)
      end

      context 'when the publication has been checked in Open Access Button before' do
        let(:last_check) { Time.zone.yesterday }

        context 'when the publication has no open access locations' do
          it 'does not create any new open access locations' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'does not update the Open Access Button check timestamp on the publication' do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.zone.yesterday
          end
        end

        context 'when the publication already has an open access location' do
          let!(:oal) { create(:open_access_location,
                              publication: pub,
                              url: 'existing_url',
                              source: Source::OPEN_ACCESS_BUTTON)}

          it 'removes the existing open access location' do
            expect { importer.import_all }.to change(OpenAccessLocation, :count).by -1
            expect { oal.reload }.to raise_error ActiveRecord::RecordNotFound
          end

          it "does not update the publication's Open Access Button check timestamp" do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to eq Time.zone.yesterday
          end
        end
      end

      context 'when the publication has never been checked in Open Access Button' do
        let(:last_check) { nil }

        context 'when the publication has no open access locations' do
          it 'does not create any new open access locations' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'updates Open Access Button check timestamp on the publication' do
            importer.import_new
            expect(pub.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
          end
        end
      end
    end
  end

  describe '#import_with_doi' do
    let!(:pub1) do
      create(:publication,
             doi: 'https://doi.org/10.000/doi1',
             title: 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes')
    end
    let!(:pub2) do
      create(:publication,
             doi: nil,
             title: 'Publication 2')
    end

    before do
      allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?id=10.000%2Fdoi1')
        .and_return(Rails.root.join('spec', 'fixtures', 'oab3.json').read)
    end

    it 'creates a new open access location for the publication' do
      expect { importer.import_with_doi }.to change(OpenAccessLocation, :count).by 1
      expect(pub1.reload.open_access_locations.count).to eq 1
    end

    it 'updates Open Access Button check timestamp on the publication' do
      importer.import_with_doi
      expect(pub1.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
    end
  end

  describe '#import_without_doi' do
    let!(:pub1) do
      create(:publication,
             doi: '',
             title: 'Stable characteristic evolution of generic three-dimensional single-black-hole spacetimes')
    end
    let!(:pub2) do
      create(:publication,
             doi: 'https://doi.org/10.000/doi1',
             title: 'Publication 2')
    end

    before do
      allow(HTTParty).to receive(:get).with('https://api.openaccessbutton.org/find?title=Stable+characteristic+evolution+of+generic+three-dimensional+single-black-hole+spacetimes')
        .and_return(Rails.root.join('spec', 'fixtures', 'oab3.json').read)
    end

    it 'creates a new open access location for the publication' do
      expect { importer.import_without_doi }.to change(OpenAccessLocation, :count).by 1
      expect(pub1.reload.open_access_locations.count).to eq 1
    end

    it 'updates Open Access Button check timestamp on the publication' do
      importer.import_without_doi
      expect(pub1.reload.open_access_button_last_checked_at).to be_within(1.minute).of(Time.zone.now)
    end
  end
end
