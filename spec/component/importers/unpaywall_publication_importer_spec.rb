# frozen_string_literal: true

require 'component/component_spec_helper'

describe UnpaywallPublicationImporter, :vcr do
  let(:importer) { described_class.new }

  describe '#import_all' do
    context 'when an existing publication does not have a DOI' do
      let!(:pub) { create :publication, doi: nil, open_access_status: nil }

      it 'does not create any open access locations for the publication' do
        expect { importer.import_all }.not_to change(OpenAccessLocation, :count)
      end

      it "does not update the publication's Unpaywall check timestamp" do
        importer.import_all
        expect(pub.reload.unpaywall_last_checked_at).to be_nil
      end

      it 'does not update the open access status on the publication' do
        importer.import_all
        expect(pub.reload.open_access_status).to be_nil
      end
    end

    context 'when an existing publication has a blank DOI' do
      let!(:pub) { create :publication, doi: '', open_access_status: nil }

      it 'does not create any open access locations for the publication' do
        expect { importer.import_all }.not_to change(OpenAccessLocation, :count)
      end

      it "does not update the publication's Unpaywall check timestamp" do
        importer.import_all
        expect(pub.reload.unpaywall_last_checked_at).to be_nil
      end

      it 'does not update the open access status on the publication' do
        importer.import_all
        expect(pub.reload.open_access_status).to be_nil
      end
    end

    context "when an existing publication's DOI does not return usable data" do
      let!(:pub) { create :publication, doi: 'https://doi.org/10.000/nodata' }

      it 'does not raise an error' do
        expect { importer.import_all }.not_to raise_error
      end
    end

    context 'when an existing publication has a DOI that corresponds to an available article listed with Unpaywall' do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.1001/jamadermatol.2015.3091' }

      context 'when the publication has no open access locations' do
        it 'creates a new open access location for the publication' do
          expect { importer.import_all }.to change { pub.open_access_locations.count }.by 1
        end

        it 'assigns the metadata from Unpaywall to the new open access location' do
          importer.import_all
          oal = pub.open_access_locations.find_by(source: Source::UNPAYWALL)
          expect(oal.url).to eq 'https://jamanetwork.com/journals/jamadermatology/articlepdf/2471551/doi150042.pdf'
        end

        it 'updates Unpaywall check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.unpaywall_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end

        it 'updates the open access status on the publication' do
          importer.import_all
          expect(pub.reload.open_access_status).to eq 'bronze'
        end
      end

      context 'when the publication already has an open access location from Unpaywall' do
        let!(:oal) { create :open_access_location,
                            publication: pub,
                            url: 'existing_url',
                            source: Source::UNPAYWALL }

        it 'does not create any new open access locations' do
          expect { importer.import_all }.not_to change(OpenAccessLocation, :count)
        end

        it 'updates the existing open access location with the URL to the open access content' do
          importer.import_all
          expect(oal.reload.url).to eq 'https://jamanetwork.com/journals/jamadermatology/articlepdf/2471551/doi150042.pdf'
        end

        it 'updates Unpaywall check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.unpaywall_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end

        it 'updates the open access status on the publication' do
          importer.import_all
          expect(pub.reload.open_access_status).to eq 'bronze'
        end
      end
    end

    context 'when an existing publication has a DOI that does not correspond to an available article listed with Unpaywall' do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.000/doi1' }

      context 'when the publication has no open access locations' do
        it 'does not create any new open access locations' do
          expect { importer.import_all }.not_to change(OpenAccessLocation, :count)
        end

        it 'updates Unpaywall check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.unpaywall_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end

        it 'does not update the open access status on the publication' do
          importer.import_all
          expect(pub.reload.open_access_status).to be_nil
        end
      end

      context 'when the publication already has an open access location' do
        let!(:oal) { create :open_access_location,
                            publication: pub,
                            url: 'existing_url',
                            source: Source::UNPAYWALL }

        it 'removes the existing open access location' do
          expect { importer.import_all }.to change(OpenAccessLocation, :count).by -1
          expect { oal.reload }.to raise_error ActiveRecord::RecordNotFound
        end

        it 'updates Unpaywall check timestamp on the publication' do
          importer.import_all
          expect(pub.reload.unpaywall_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end

        it 'does not update the open access status on the publication' do
          importer.import_all
          expect(pub.reload.open_access_status).to be_nil
        end
      end
    end

    context 'when an error is raised' do
      let!(:pub) { create :publication, doi: 'https://doi.org/10.000/nodata' }

      before do
        allow(JSON).to receive(:parse).and_raise(RuntimeError)
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
              unpaywall_json: ''
            }
          )
      end

      it 'continues with the import' do
        create :publication, doi: 'https://doi.org/10.000/nodata'
        importer.import_all
        expect(ImporterErrorLog).to have_received(:log_error).twice
      end
    end
  end

  context 'when the API request times out too many times' do
    let!(:pub) { create :publication, doi: 'https://doi.org/10.000/nodata' }

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
            unpaywall_json: ''
          }
        )
    end

    it 'continues with the import' do
      create :publication, doi: 'https://doi.org/10.000/nodata'
      importer.import_all
      expect(ImporterErrorLog).to have_received(:log_error).twice
    end
  end

  describe '#import_new' do
    context 'when an existing publication does not have a DOI' do
      let!(:pub) { create :publication, doi: nil, open_access_status: nil }

      it 'does not create any open access locations for the publication' do
        expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
      end

      it "does not update the publication's Unpaywall check timestamp" do
        importer.import_new
        expect(pub.reload.unpaywall_last_checked_at).to be_nil
      end

      it 'does not update the open access status on the publication' do
        importer.import_new
        expect(pub.reload.open_access_status).to be_nil
      end
    end

    context 'when an existing publication has a blank DOI' do
      let!(:pub) { create :publication, doi: '', open_access_status: nil }

      it 'does not create any open access locations for the publication' do
        expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
      end

      it "does not update the publication's Unpaywall check timestamp" do
        importer.import_new
        expect(pub.reload.unpaywall_last_checked_at).to be_nil
      end

      it 'does not update the open access status on the publication' do
        importer.import_new
        expect(pub.reload.open_access_status).to be_nil
      end
    end

    context "when an existing publication's DOI does not return usable data" do
      let!(:pub) { create :publication, doi: 'https://doi.org/10.000/nodata' }

      it 'does not raise an error' do
        expect { importer.import_new }.not_to raise_error
      end
    end

    context 'when an existing publication has a DOI that corresponds to an available article listed with Unpaywall' do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.1001/jamadermatol.2015.3091',
                          unpaywall_last_checked_at: last_check,
                          open_access_status: 'green' }

      context 'when the publication has been checked in Unpaywall before' do
        let(:last_check) { Time.zone.yesterday }

        context 'when the publication has no open access locations' do
          it 'does not create any open access locations for the publication' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'does not update the Unpaywall check timestamp on the publication' do
            importer.import_new
            expect(pub.reload.unpaywall_last_checked_at).to eq Time.zone.yesterday
          end

          it 'does not update the open access status on the publication' do
            importer.import_new
            expect(pub.reload.open_access_status).to eq 'green'
          end
        end

        context 'when the publication already has an open access location' do
          let!(:oal) { create :open_access_location,
                              publication: pub,
                              url: 'existing_url',
                              source: Source::UNPAYWALL }

          it 'does not create any new open access locations' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'does not update the URL for the existing open access location' do
            importer.import_new
            expect(oal.reload.url).to eq 'existing_url'
          end

          it "does not update the publication's Unpaywall check timestamp" do
            importer.import_new
            expect(pub.reload.unpaywall_last_checked_at).to eq Time.zone.yesterday
          end

          it 'does not update the open access status on the publication' do
            importer.import_new
            expect(pub.reload.open_access_status).to eq 'green'
          end
        end
      end

      context 'when the publication has never been checked in Unpaywall' do
        let(:last_check) { nil }

        it 'creates a new open access location for the publication' do
          expect { importer.import_new }.to change { pub.open_access_locations.count }.by 1
        end

        it 'assigns the metadata from Unpaywall to the new open access location' do
          importer.import_new
          oal = pub.open_access_locations.find_by(source: Source::UNPAYWALL)
          expect(oal.url).to eq 'https://jamanetwork.com/journals/jamadermatology/articlepdf/2471551/doi150042.pdf'
        end

        it 'updates Unpaywall check timestamp on the publication' do
          importer.import_new
          expect(pub.reload.unpaywall_last_checked_at).to be_within(1.minute).of(Time.zone.now)
        end

        it 'updates the open access status on the publication' do
          importer.import_new
          expect(pub.reload.open_access_status).to eq 'bronze'
        end
      end
    end

    context 'when an existing publication has a DOI that does not correspond to an available article listed with Unpaywall' do
      let!(:pub) { create :publication,
                          doi: 'https://doi.org/10.000/doi1',
                          unpaywall_last_checked_at: last_check,
                          open_access_status: nil }

      context 'when the publication has been checked in Unpaywall before' do
        let(:last_check) { Time.zone.yesterday }

        context 'when the publication has no open access locations' do
          it 'does not create any new open access locations' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'does not update the Unpaywall check timestamp on the publication' do
            importer.import_new
            expect(pub.reload.unpaywall_last_checked_at).to eq Time.zone.yesterday
          end

          it 'does not update the open access status on the publication' do
            importer.import_new
            expect(pub.reload.open_access_status).to be_nil
          end
        end

        context 'when the publication already has an open access location' do
          let!(:oal) { create :open_access_location,
                              publication: pub,
                              url: 'existing_url',
                              source: Source::UNPAYWALL }

          it 'removes the existing open access location' do
            expect { importer.import_all }.to change(OpenAccessLocation, :count).by -1
            expect { oal.reload }.to raise_error ActiveRecord::RecordNotFound
          end

          it "does not update the publication's Unpaywall check timestamp" do
            importer.import_new
            expect(pub.reload.unpaywall_last_checked_at).to eq Time.zone.yesterday
          end

          it 'does not update the open access status on the publication' do
            importer.import_new
            expect(pub.reload.open_access_status).to be_nil
          end
        end
      end

      context 'when the publication has never been checked in Unpaywall' do
        let(:last_check) { nil }

        context 'when the publication has no open access locations' do
          it 'does not create any new open access locations' do
            expect { importer.import_new }.not_to change(OpenAccessLocation, :count)
          end

          it 'updates Unpaywall check timestamp on the publication' do
            importer.import_new
            expect(pub.reload.unpaywall_last_checked_at).to be_within(1.minute).of(Time.zone.now)
          end

          it 'does not update the open access status on the publication' do
            importer.import_new
            expect(pub.reload.open_access_status).to be_nil
          end
        end
      end
    end
  end
end
