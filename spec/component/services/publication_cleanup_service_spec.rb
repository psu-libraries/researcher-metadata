# frozen_string_literal: true

require 'component/component_spec_helper'

describe PublicationCleanupService do
  describe '.clean_up_pure_publications' do
    context 'with dependencies mocked' do
      let(:relation) { instance_double ActiveRecord::Relation }
      let(:pub) { instance_spy Publication, id: 123 }
      let(:ppf) { instance_double PurePersonFinder }

      before do
        allow(relation).to receive(:find_each).and_yield(pub)
        allow(Publication).to receive(:with_only_pure_imports).and_return relation
        allow(PurePersonFinder).to receive(:new).and_return ppf
      end

      context 'when a publication with only Pure imports is not in the current list of Pure publications' do
        before { allow(SourcePublication).to receive(:find_in_latest_pure_list).with(pub).and_return nil }

        context 'when the publication has an author that is currently in Pure' do
          before { allow(ppf).to receive(:detect_publication_author).with(pub).and_return(instance_double(User)) }

          context 'when the dry_run option is not set' do
            it 'outputs a message saying that the publication will be deleted' do
              expect { described_class.clean_up_pure_publications }.to output("Publication 123 will be deleted\n").to_stdout
            end

            it 'does not delete the publication' do
              described_class.clean_up_pure_publications
              expect(pub).not_to have_received(:destroy!)
            end
          end

          context 'when the dry_run option is set to false' do
            it 'outputs a message saying the the publication is being deleted' do
              expect { described_class.clean_up_pure_publications(dry_run: false) }.to output("Deleting publication 123\n").to_stdout
            end

            it 'deletes the publication' do
              described_class.clean_up_pure_publications(dry_run: false)
              expect(pub).to have_received(:destroy!)
            end
          end
        end

        context 'when the publication has no authors that are currently in Pure' do
          before { allow(ppf).to receive(:detect_publication_author).with(pub).and_return(nil) }

          context 'when the dry_run option is not set' do
            it 'does not delete the publication' do
              described_class.clean_up_pure_publications
              expect(pub).not_to have_received(:destroy!)
            end
          end

          context 'when the dry_run option is set to false' do
            it 'does not delete the publication' do
              described_class.clean_up_pure_publications(dry_run: false)
              expect(pub).not_to have_received(:destroy!)
            end
          end
        end
      end

      context 'when a publication with only Pure imports is in the current list of Pure publications' do
        before { allow(SourcePublication).to receive(:find_in_latest_pure_list).with(pub).and_return pub }

        context 'when the publication has an author that is currently in Pure' do
          before { allow(ppf).to receive(:detect_publication_author).with(pub).and_return(instance_double(User)) }

          context 'when the dry_run option is not set' do
            it 'does not delete the publication' do
              described_class.clean_up_pure_publications
              expect(pub).not_to have_received(:destroy!)
            end
          end

          context 'when the dry_run option is set to false' do
            it 'does not delete the publication' do
              described_class.clean_up_pure_publications(dry_run: false)
              expect(pub).not_to have_received(:destroy!)
            end
          end
        end

        context 'when the publication has no authors that are currently in Pure' do
          before { allow(ppf).to receive(:detect_publication_author).with(pub).and_return(nil) }

          context 'when the dry_run option is not set' do
            it 'does not delete the publication' do
              described_class.clean_up_pure_publications
              expect(pub).not_to have_received(:destroy!)
            end
          end

          context 'when the dry_run option is set to false' do
            it 'does not delete the publication' do
              described_class.clean_up_pure_publications(dry_run: false)
              expect(pub).not_to have_received(:destroy!)
            end
          end
        end
      end
    end

    context 'with real internal dependencies' do
      let!(:pub1) { create(:publication) }
      let!(:pub1_author) { create(:user, pure_uuid: 'asdfghjkl') }

      let!(:pub2) { create(:publication) }
      let!(:pub2_author) { create(:user, pure_uuid: 'qwertyui') }

      let!(:pub3) { create(:publication) }
      let!(:pub3_author) { create(:user, pure_uuid: 'zxcvbnm') }

      let!(:latest_pure_import) {
        create(
          :import,
          source: 'Pure',
          started_at: 2.hours.ago,
          completed_at: 1.hour.ago
        )
      }

      before do
        create(:publication_import, publication: pub1, source: 'Pure', source_identifier: 'abc123')
        create(:authorship, user: pub1_author, publication: pub1)
        create(:source_publication, source_identifier: 'abc123', import: latest_pure_import)

        create(:publication_import, publication: pub2, source: 'Pure', source_identifier: 'def456')
        create(:authorship, user: pub2_author, publication: pub2)

        create(:publication_import, publication: pub3, source: 'Pure', source_identifier: 'jkl789')
        create(:authorship, user: pub3_author, publication: pub3)

        allow(HTTParty).to receive(:get).with(
          'https://pure.psu.edu/ws/api/524/persons/qwertyui',
          headers: { 'api-key' => Settings.pure.api_key }
        ).and_return(instance_double(HTTParty::Response, code: 200))

        allow(HTTParty).to receive(:get).with(
          'https://pure.psu.edu/ws/api/524/persons/zxcvbnm',
          headers: { 'api-key' => Settings.pure.api_key }
        ).and_return(instance_double(HTTParty::Response, code: 404))
      end

      it 'deletes the correct publications' do
        expect {
          described_class.clean_up_pure_publications(dry_run: false)
        }.to change(Publication, :count).by(-1)

        expect { pub2.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
