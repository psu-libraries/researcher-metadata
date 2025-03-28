# frozen_string_literal: true

require 'component/component_spec_helper'
require_relative '../../../../lib/utilities/works_generator'

describe Utilities::WorksGenerator do
  let!(:user) { create(:user, webaccess_id: 'abc123') }
  let(:generator) { described_class.new(user.webaccess_id) }

  context 'when Rails.env is production' do
    it 'raises error' do
      allow(Rails.env).to receive(:production?).and_return(true)
      expect { described_class.new('abc123').other_work }.to raise_error RuntimeError
    end
  end

  context 'when webaccess id does not match any users' do
    it 'creates a sample user' do
      expect { described_class.new('fgh678').other_work }.to change(User, :count).by 1
      expect(User.last.webaccess_id).to eq('fgh678')
    end
  end

  describe '#oa_publication_no_open_access_location' do
    it 'generates an oa policy publication with no open access url' do
      expect { generator.oa_publication_no_open_access_location }.to change(Publication, :count).by 1
      expect(Publication.last.open_access_locations.count).to eq 0
    end
  end

  describe '#oa_publication_with_open_access_location' do
    it 'generates an oa policy publication with one open access url' do
      expect { generator.oa_publication_with_open_access_location }.to change(Publication, :count).by 1
      expect(Publication.last.open_access_locations.count).to eq 1
    end
  end

  describe '#oa_publication_in_press' do
    it 'generates an oa policy publication with a status of "In Press"' do
      expect { generator.oa_publication_in_press }.to change(Publication, :count).by 1
      expect(Publication.last.status).to eq 'In Press'
    end
  end

  describe '#other_work' do
    it 'generates a non oa policy publication' do
      expect { generator.other_work }.to change(Publication, :count).by 1
      expect(Publication.oa_publication_types.exclude?(Publication.last.publication_type)).to be true
    end
  end

  describe '#oa_publication_from_activity_insight' do
    it 'generates an oa policy publication whos publication import source is Activity Insight' do
      expect { generator.oa_publication_from_activity_insight }.to change(Publication, :count).by 1
      expect(Publication.last.imports.first.source).to eq 'Activity Insight'
    end
  end

  describe '#oa_publication_duplicate_group' do
    it 'generates an oa policy publication that is part of a duplicate group' do
      expect { generator.oa_publication_duplicate_group }.to change(Publication, :count).by 2
      expect(Publication.last.duplicate_group.publications.count).to eq 2
    end
  end

  describe '#oa_publication_non_duplicate_group' do
    it 'generates an oa policy publication that is part of a duplicate group that is also a non duplicate group' do
      expect { generator.oa_publication_non_duplicate_group }.to change(Publication, :count).by 2
      expect(Publication.last.non_duplicate_groups.count).to eq 1
      expect(Publication.last.duplicate_group.publications.sort).to eq Publication.last.non_duplicate_groups.first.publications.sort
    end
  end

  describe '#presentation' do
    it 'generates a presentation' do
      expect { generator.presentation }.to change(Presentation, :count).by 1
      expect(user.presentations.first).to eq Presentation.last
    end
  end

  describe '#performance' do
    it 'generates a performance' do
      expect { generator.presentation }.to change(Presentation, :count).by 1
      expect(user.performances.first).to eq Performance.last
    end
  end
end
