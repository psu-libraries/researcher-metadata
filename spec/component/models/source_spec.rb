# frozen_string_literal: true

require 'component/component_spec_helper'

describe Source do
  specify { expect(described_class::USER).to eq 'user' }
  specify { expect(described_class::SCHOLARSPHERE).to eq 'scholarsphere' }
  specify { expect(described_class::OPEN_ACCESS_BUTTON).to eq 'open_access_button' }
  specify { expect(described_class::UNPAYWALL).to eq 'unpaywall' }
  specify { expect(described_class::DICKINSON_IDEAS).to eq 'dickinson_ideas' }
  specify { expect(described_class::PSU_LAW_ELIBRARY).to eq 'psu_law_elibrary' }
  specify { expect(described_class::DICKINSON_INSIGHT).to eq 'dickinson_insight' }

  describe '#eql?' do
    it 'compares to strings' do
      expect(described_class.new('user')).to eq 'user'
    end
  end

  describe '#display' do
    {
      described_class::USER => 'User',
      described_class::SCHOLARSPHERE => 'ScholarSphere',
      described_class::OPEN_ACCESS_BUTTON => 'Open Access Button',
      described_class::UNPAYWALL => 'Unpaywall',
      described_class::DICKINSON_IDEAS => 'Dickinson Law IDEAS Repo',
      described_class::PSU_LAW_ELIBRARY => 'Penn State Law eLibrary Repo',
      described_class::DICKINSON_INSIGHT => 'Dickinson Law INSIGHT Repo'
    }.each do |source, expected_display_value|
      it "translates #{source.inspect} into #{expected_display_value.inspect}" do
        src = described_class.new(source)
        expect(src.display).to eq expected_display_value
      end
    end
  end

  describe '#to_s' do
    it 'returns the string value of the source' do
      src = described_class.new(described_class::OPEN_ACCESS_BUTTON)
      expect(src.to_s).to eq described_class::OPEN_ACCESS_BUTTON
    end
  end
end
