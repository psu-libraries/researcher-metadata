# frozen_string_literal: true

require 'component/component_spec_helper'

describe WorksGenerator do
  let!(:user) { FactoryBot.create :user, webaccess_id: 'abc123' }

  describe '#journal_article_no_open_access_location' do
    it 'generates a journal article with no open access url' do
      expect { described_class.new(user.webaccess_id).journal_article_no_open_access_location }.to change(Publication, :count).by 1
      expect(Publication.last.open_access_locations.count).to eq 0
    end
  end

  describe '#journal_article_with_open_access_location' do
    it 'generates a journal article with one open access url' do
      expect { described_class.new(user.webaccess_id).journal_article_with_open_access_location }.to change(Publication, :count).by 1
      expect(Publication.last.open_access_locations.count).to eq 1
    end
  end

  describe '#journal_article_in_press' do
    it 'generates a journal article with a status of "In Press"' do
      expect { described_class.new(user.webaccess_id).journal_article_in_press }.to change(Publication, :count).by 1
      expect(Publication.last.status).to eq 'In Press'
    end
  end

  describe '#other_work' do
    it 'generates a non journal article publication' do
      expect { described_class.new(user.webaccess_id).other_work }.to change(Publication, :count).by 1
      expect(Publication.last.publication_type).not_to match(/Journal Article/)
    end
  end

  describe '#journal_article_from_activity_insight' do
    it 'generates a journal article whos publication import source is Activity Insight' do
      expect { described_class.new(user.webaccess_id).other_work }.to change(Publication, :count).by 1
      expect(Publication.last.publication_type).not_to match(/Journal Article/)
    end
  end

  describe '#journal_article_duplicate_group' do
    it 'generates a journal article that is part of a duplicate group' do
      expect { described_class.new(user.webaccess_id).journal_article_duplicate_group }.to change(Publication, :count).by 2
      expect(Publication.last.duplicate_group.publications.count).to eq 2
    end
  end

  describe '#journal_article_non_duplicate_group' do
    it 'generates a journal article that is part of a non duplicate group' do
      expect { described_class.new(user.webaccess_id).journal_article_non_duplicate_group }.to change(Publication, :count).by 2
      expect(Publication.last.non_duplicate_groups.count).to eq 1
      expect(Publication.last.duplicate_group.publications.sort).to eq Publication.last.non_duplicate_groups.first.publications.sort
    end
  end
end