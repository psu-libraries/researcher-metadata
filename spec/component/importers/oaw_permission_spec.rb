# frozen_string_literal: true

require 'component/component_spec_helper'

describe OAWPermission do
  let(:permission) { described_class.new(data) }
  let(:data) {
    {
      'version' => 'acceptedVersion',
      'can_archive' => can_archive,
      'locations' => locations,
      'requirements' => requirements
    }
  }

  let(:can_archive) { true }
  let(:locations) { [] }
  let(:requirements) { nil }

  describe '#version' do
    it 'returns the publication version to which the permission policy applies' do
      expect(permission.version).to eq 'acceptedVersion'
    end
  end

  describe '#can_archive_in_institutional_repository?' do
    context 'when permissions policy indicates that the publication can be archived' do
      context "when the list of locations for archival includes 'Institutional Repository" do
        let(:locations) { ['other', 'Institutional Repository'] }

        it 'returns true' do
          expect(permission.can_archive_in_institutional_repository?).to be true
        end
      end

      context "when the list of locations for archival includes 'institutional repository" do
        let(:locations) { ['other', 'institutional repository'] }

        it 'returns true' do
          expect(permission.can_archive_in_institutional_repository?).to be true
        end
      end

      context "when the list of locations for archival does not include 'institutional repository" do
        let(:locations) { ['other'] }

        it 'returns false' do
          expect(permission.can_archive_in_institutional_repository?).to be false
        end
      end

      context 'when there are no locations listed for archival' do
        it 'returns false' do
          expect(permission.can_archive_in_institutional_repository?).to be false
        end
      end
    end

    context 'when permissions policy indicates that the publication cannot be archived' do
      let(:can_archive) { false }

      context "when the list of locations for archival includes 'Institutional Repository" do
        let(:locations) { ['other', 'Institutional Repository'] }

        it 'returns false' do
          expect(permission.can_archive_in_institutional_repository?).to be false
        end
      end

      context "when the list of locations for archival includes 'institutional repository" do
        let(:locations) { ['other', 'institutional repository'] }

        it 'returns false' do
          expect(permission.can_archive_in_institutional_repository?).to be false
        end
      end

      context "when the list of locations for archival does not include 'institutional repository" do
        let(:locations) { ['other'] }

        it 'returns false' do
          expect(permission.can_archive_in_institutional_repository?).to be false
        end
      end

      context 'when there are no locations listed for archival' do
        it 'returns false' do
          expect(permission.can_archive_in_institutional_repository?).to be false
        end
      end
    end
  end

  describe '#has_requirements?' do
    context 'when the permissions policy has no list of requirements' do
      it 'returns false' do
        expect(permission.has_requirements?).to be false
      end
    end

    context 'when the permissions policy has an empty list of requirements' do
      let(:requirements) { {} }

      it 'returns false' do
        expect(permission.has_requirements?).to be false
      end
    end

    context 'when the permissions policy has a list of requirements' do
      let(:requirements) { { 'funder' => ['test'] } }

      it 'returns true' do
        expect(permission.has_requirements?).to be true
      end
    end
  end
end
