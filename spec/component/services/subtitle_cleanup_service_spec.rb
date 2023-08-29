# frozen_string_literal: true

require 'component/component_spec_helper'

describe SubtitleCleanupService do
  let!(:publication1) { create(:sample_publication) }
  let!(:publication2) { create(:sample_publication) }
  let!(:publication3) { create(:sample_publication) }
  let!(:publication4) { create(:sample_publication, secondary_title: nil) }
  let!(:publication5) { create(:sample_publication, secondary_title: '') }
  let!(:publication6) { create(:sample_publication) }
  let!(:publication7) { create(:sample_publication) }

  before do
    publication1.update title: "#{publication1.title}: #{publication1.secondary_title}"
    publication2.update title: "#{publication2.title}: #{publication2.secondary_title}"
    publication3.update title: publication3.secondary_title
  end

  describe '.call' do
    subject(:call) { described_class.call }

    it 'updates secondary_title to nil if secondary_title is included in the title' do
      call
      expect(publication1.reload.secondary_title).to be_nil
      expect(publication2.reload.secondary_title).to be_nil
      expect(publication3.reload.secondary_title).to be_nil
      expect(publication4.reload).to eq publication4
      expect(publication5.reload).to eq publication5
      expect(publication6.reload).to eq publication6
      expect(publication7.reload).to eq publication7
    end
  end
end
