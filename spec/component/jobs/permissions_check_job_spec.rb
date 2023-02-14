# frozen_string_literal: true

require 'component/component_spec_helper'

describe PermissionsCheckJob, type: :job do
  describe '#perform' do
    let!(:publication) { create(:publication,
                                doi: 'https://doi.org/10.1016/S0962-1849(05)80014-9')}
    let!(:activity_insight_oa_file1) { create(:activity_insight_oa_file, publication: publication) }
    let!(:activity_insight_oa_file2) { create(:activity_insight_oa_file, publication: publication) }
    let!(:activity_insight_oa_file3) { create(:activity_insight_oa_file, publication: publication) }
    let(:job) { described_class.new }

    context 'when the preferred version is the correct version' do
      it 'updates the publication permissions' do
        job.perform(publication)
        expect(publication.reload.permissions_last_checked_at).not_to be_nil
        expect(publication.reload.set_statement).to eq '© This manuscript version is made available under the CC-BY-NC-ND 4.0 license https://creativecommons.org/licenses/by-nc-nd/4.0/'
        expect(publication.reload.licence).to eq 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
      end
    end

    context 'when the preferred version is not the correct version' do
      let!(:publication) { create(:publication,
                                   doi: nil)}
      it 'does not update the publication permissions' do
        job.perform(publication)
        expect(publication.reload.permissions_last_checked_at).not_to be_nil
        expect(publication.reload.set_statement).to be_nil
        expect(publication.reload.licence).to be_nil
      end
    end
  end
end