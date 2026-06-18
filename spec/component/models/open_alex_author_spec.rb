# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAlexAuthor do
  let(:author) { described_class.new(author_data, 0) }
  let(:author_data) {
    {
      'author' => {
        'orcid' => 'orcid123',
        'display_name' => name
      },
      'institutions' => institutions
    }
  }
  let(:name) { 'Jane P. Author' }
  let(:institutions) { [] }

  describe '#orcid' do
    it "returns the author's ORCiD from the given metadata" do
      expect(author.orcid).to eq 'orcid123'
    end
  end

  describe '#position' do
    it 'returns the given index plus 1' do
      expect(author.position).to eq 1
    end
  end

  describe '#first_name' do
    it "returns the first part of the author's display_name from the given metadata" do
      expect(author.first_name).to eq 'Jane'
    end
  end

  describe '#middle_name' do
    context "when the author's display_name in the given metadata has 2 parts" do
      let(:name) { 'Jane Author' }

      it 'returns nil' do
        expect(author.middle_name).to be_nil
      end
    end

    context "when the author's display_name in the given metadata has 3 parts" do
      it 'returns the middle part' do
        expect(author.middle_name).to eq 'P.'
      end
    end

    context "when the author's display_name in the given metadata has 4 parts" do
      let(:name) { 'Jane P. R. Author' }

      it 'returns the middle two parts as one string' do
        expect(author.middle_name).to eq 'P. R.'
      end
    end
  end

  describe '#last_name' do
    context "when the author's display_name in the given metadata has 2 parts" do
      let(:name) { 'Jane Author' }

      it 'returns the last part' do
        expect(author.last_name).to eq 'Author'
      end
    end

    context "when the author's display_name in the given metadata has 3 parts" do
      it 'returns the last part' do
        expect(author.last_name).to eq 'Author'
      end
    end

    context "when the author's display_name in the given metadata has 4 parts" do
      let(:name) { 'Jane P. R. Author' }

      it 'returns the last part' do
        expect(author.last_name).to eq 'Author'
      end
    end
  end

  describe '#psu_affiliated?' do
    context "when the author has no institutions with Penn State's ROR ID in the given metadata" do
      let(:institutions) {
        [
          {
            'ror' => 'non-psu-ror-id'
          }
        ]
      }

      it 'returns false' do
        expect(author.psu_affiliated?).to be false
      end
    end

    context "when the author has an institution with Penn State's ROR ID in the given metadata" do
      let(:institutions) {
        [
          {
            'ror' => 'non-psu-ror-id'
          },
          {
            'ror' => 'https://ror.org/04p491231'
          }
        ]
      }

      it 'returns true' do
        expect(author.psu_affiliated?).to be true
      end
    end
  end
end
