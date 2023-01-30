# frozen_string_literal: true

require 'component/component_spec_helper'

describe DoiVerificationMergePolicy do
  let(:policy) { described_class.new publications }
  let(:publications) { [pub1, pub2, pub3] }
  let(:pub1) { create(:publication, doi_verified: nil) }

  describe '#doi_verification_to_keep' do
    context 'when one of the publications has a verified doi' do
      let(:pub2) { create(:publication, doi_verified: true) }
      let(:pub3) { create(:publication, doi_verified: false) }

      it 'picks true' do
        expect(policy.doi_verification_to_keep).to be true
      end
    end

    context 'when none of the publications have a verified doi' do
      let(:pub2) { create(:publication, doi_verified: nil) }

      context 'when one of the publications has a false verification' do
        let(:pub3) { create(:publication, doi_verified: false) }

        it 'picks false' do
          expect(policy.doi_verification_to_keep).to be false
        end
      end

      context 'when all publications have a nil verification' do
        let(:pub3) { create(:publication, doi_verified: nil) }

        it 'picks nil' do
          expect(policy.doi_verification_to_keep).to be_nil
        end
      end
    end
  end
end
