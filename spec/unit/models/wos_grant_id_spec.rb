# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/models/wos_grant_id'

describe WOSGrantId do
  let(:parsed_grant_id) { double 'parsed grant ID' }
  let(:grant) { double 'grant' }
  let(:grant_id) { described_class.new(grant, parsed_grant_id) }

  describe '#wos_value' do
    before { allow(parsed_grant_id).to receive(:text).and_return("  \n ABC123456\n  ") }

    it 'returns the name of the identifier for the grant with any surrounding whitespace removed' do
      expect(grant_id.wos_value).to eq 'ABC123456'
    end
  end

  describe '#value' do
    context "when the given grant's agency is 'National Science Foundation'" do
      before { allow(grant).to receive(:agency).and_return 'National Science Foundation' }

      context "when the grant ID in the given data is '123456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('123456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is '123456' with surrounding whitespace" do
        before { allow(parsed_grant_id).to receive(:text).and_return("  \n123456 \n  ") }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is 'ABC-123456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('ABC-123456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is 'NSF-ABC-123456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('NSF-ABC-123456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is 'NSF-ABC 123456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('NSF-ABC 123456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is '12-3456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('12-3456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is 'NSF ABC 12-3456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('NSF ABC 12-3456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is 'ABC 12-3456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('ABC 12-3456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end

      context "when the grant ID in the given data is 'ABC12-3456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('ABC12-3456') }

        it "returns '123456'" do
          expect(grant_id.value).to eq '123456'
        end
      end
    end

    context "when the given grant's agency is 'Other Agency'" do
      before { allow(grant).to receive(:agency).and_return 'Other Agency' }

      context "when the grant ID in the given data is '123456'" do
        before { allow(parsed_grant_id).to receive(:text).and_return('123456') }

        it 'returns nil' do
          expect(grant_id.value).to be_nil
        end
      end
    end
  end
end
