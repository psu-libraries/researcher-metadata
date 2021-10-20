# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAccessUrlsMigrationService do
  before do
    5.times { create :publication, open_access_url: 'example.com' }
    5.times { create :publication, scholarsphere_open_access_url: 'scholarsphere.edu' }
    5.times { create :publication, user_submitted_open_access_url: 'user_example.com' }
    5.times do
      create :publication, user_submitted_open_access_url: 'user_example.com', open_access_url: 'example.com'
    end
    5.times do
      create :publication, scholarsphere_open_access_url: 'scholarsphere.edu', open_access_url: 'example.com'
    end
    5.times do
      create :publication, user_submitted_open_access_url: 'user_example.com',
             scholarsphere_open_access_url: 'scholarsphere.edu'
    end
    5.times do
      create :publication, user_submitted_open_access_url: 'user_example.com',
             scholarsphere_open_access_url: 'scholarsphere.edu',
             open_access_url: 'example.com'
    end
  end

  describe '#call' do
    it 'creates OpenAccessLocation records from Publication open access url data' do
      expect{ described_class.call }.to change{ OpenAccessLocation.count }.by 60
    end

    it 'creates OpenAccessLocation records with proper attributes' do
      oa_url_pub = create :publication, open_access_url: 'oa_url.com'
      ss_oa_url_pub = create :publication, scholarsphere_open_access_url: 'ss_oa_url.edu'
      user_oa_url_pub = create :publication, user_submitted_open_access_url: 'user_oa_url.com'

      described_class.call
      expect(OpenAccessLocation.find_by(url: oa_url_pub.open_access_url).source).to eq 'Open Access Button'
      expect(OpenAccessLocation.find_by(url: oa_url_pub.open_access_url).publication_id).to eq oa_url_pub.id
      expect(OpenAccessLocation.find_by(url: ss_oa_url_pub.scholarsphere_open_access_url).source).to eq 'ScholarSphere'
      expect(OpenAccessLocation.find_by(url: ss_oa_url_pub.scholarsphere_open_access_url).publication_id).to eq ss_oa_url_pub.id
      expect(OpenAccessLocation.find_by(url: user_oa_url_pub.user_submitted_open_access_url).source).to eq 'User'
      expect(OpenAccessLocation.find_by(url: user_oa_url_pub.user_submitted_open_access_url).publication_id).to eq user_oa_url_pub.id
    end

    it 'is idempotent' do
      described_class.call
      expect{ described_class.call }.not_to change{ OpenAccessLocation.count }
    end
  end
end
