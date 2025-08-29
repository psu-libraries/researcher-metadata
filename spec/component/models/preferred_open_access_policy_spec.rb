# frozen_string_literal: true

require 'component/component_spec_helper'

describe PreferredOpenAccessPolicy do
  let(:policy) { described_class.new(open_access_locations) }
  let(:open_access_locations) { [] }

  describe 'preferences of sources, (first is most preferred, last is least preferred)' do
    let(:all_valid_sources) { OpenAccessLocation.sources.map { |_k, val| val } }
    let(:open_access_locations) {
      all_valid_sources
        .sort_by { rand }
        .map { |s|
        OpenAccessLocation.new(source: s, url: 'url', is_best: false)
      }
    }

    specify do
      expect(policy.rank_all.map(&:source).map(&:to_s)).to eq [
        # Most preferred
        Source::SCHOLARSPHERE,
        Source::DICKINSON_INSIGHT,
        Source::DICKINSON_IDEAS,
        Source::PSU_LAW_ELIBRARY,
        Source::OPEN_ACCESS_BUTTON,
        Source::UNPAYWALL,
        Source::USER
        # Least preferred
      ]
    end
  end

  describe '#url' do
    context 'when there are blank urls' do
      let(:open_access_locations) { [
        OpenAccessLocation.new(source: Source::SCHOLARSPHERE, url: '', is_best: false),
        OpenAccessLocation.new(source: Source::OPEN_ACCESS_BUTTON, url: nil, is_best: false),
        OpenAccessLocation.new(source: Source::USER, url: 'USER url', is_best: false)
      ]}

      it 'considers only OALs with URLs' do
        expect(policy.url).to eq 'USER url'
      end
    end

    context 'when multiple locations are present' do
      context 'when ScholarSphere is present' do
        let(:open_access_locations) { [
          OpenAccessLocation.new(source: Source::OPEN_ACCESS_BUTTON, url: 'OPEN_ACCESS_BUTTON url', is_best: false),
          OpenAccessLocation.new(source: Source::SCHOLARSPHERE, url: 'SCHOLARSPHERE url', is_best: false),
          OpenAccessLocation.new(source: Source::USER, url: 'USER url', is_best: false)
        ]}

        it 'is picked' do
          expect(policy.url).to eq 'SCHOLARSPHERE url'
        end
      end

      context 'when OAB is present' do
        let(:open_access_locations) { [
          OpenAccessLocation.new(source: Source::UNPAYWALL, url: 'UNPAYWALL url', is_best: false),
          OpenAccessLocation.new(source: Source::USER, url: 'USER url', is_best: false),
          OpenAccessLocation.new(source: Source::OPEN_ACCESS_BUTTON, url: 'OPEN_ACCESS_BUTTON url', is_best: false)
        ]}

        it 'is picked' do
          expect(policy.url).to eq 'OPEN_ACCESS_BUTTON url'
        end
      end

      context 'when an unknown source is present' do
        let(:open_access_locations) { [
          OpenAccessLocation.new(source: Source::USER, url: 'USER url', is_best: false),
          instance_double(OpenAccessLocation, source: 'wacky', url: 'wacky url', is_best: false)
        ]}

        it 'is the least preferred option' do
          expect(policy.url).to eq 'USER url'
        end
      end

      context 'when there are multiple choices from the same source' do
        context 'when one is_best' do
          let(:open_access_locations) { [
            OpenAccessLocation.new(source: Source::UNPAYWALL, url: 'not best url', is_best: false),
            OpenAccessLocation.new(source: Source::UNPAYWALL, url: 'best url', is_best: true)
          ]}

          it 'picks the one where is_best is true' do
            expect(policy.url).to eq 'best url'
          end
        end

        context 'when none are marked is_best' do
          let(:open_access_locations) { [
            OpenAccessLocation.new(source: Source::UNPAYWALL, url: 'not best url', is_best: false),
            OpenAccessLocation.new(source: Source::UNPAYWALL, url: 'also not best url', is_best: false)
          ]}

          it 'randomly picks one' do
            expect(policy.url).to be_present
          end
        end

        context 'when the OALs with is_best are mixed in with more preferred sources' do
          let(:open_access_locations) { [
            OpenAccessLocation.new(source: Source::UNPAYWALL, url: 'UNPAYWALL not best url', is_best: false),
            OpenAccessLocation.new(source: Source::UNPAYWALL, url: 'UNPAYWALL best url', is_best: true),
            OpenAccessLocation.new(source: Source::SCHOLARSPHERE, url: 'SCHOLARSPHERE url', is_best: false)
          ]}

          it 'ranks the source higher than is_best' do
            expect(policy.url).to eq 'SCHOLARSPHERE url'
          end
        end
      end
    end
  end
end
