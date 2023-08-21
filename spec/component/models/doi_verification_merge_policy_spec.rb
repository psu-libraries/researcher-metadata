# frozen_string_literal: true

require 'component/component_spec_helper'

describe DOIVerificationMergePolicy do
  let(:policy) { described_class.new(pub1, publications) }
  let(:publications) { [pub1, pub2, pub3] }
  let(:pub1) { create(:publication, doi_verified: nil, doi: nil) }

  describe '#merge!' do
    context 'when one of the publications has a verified doi' do
      let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1103/physrevlett.80.3915') }
      let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

      it 'picks that doi and verification' do
        policy.merge!
        expect(pub1.doi_verified).to be true
        expect(pub1.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
      end
    end

    context 'when none of the publications have a verified doi' do
      let(:pub2) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1103/physrevlett.80.3915') }

      context 'when one of the publications has a false verification' do
        let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        it 'picks that doi and verification' do
          policy.merge!
          expect(pub1.doi_verified).to be false
          expect(pub1.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
        end
      end

      context 'when all publications have a nil verification' do
        let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        it 'does not update doi or verification' do
          policy.merge!
          expect(pub1.doi_verified).to be_nil
          expect(pub1.doi).to be_nil
        end
      end
    end
  end
end
