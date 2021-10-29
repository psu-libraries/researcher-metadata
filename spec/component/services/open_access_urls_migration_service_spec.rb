# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAccessUrlsMigrationService do
  before do
    create_list :publication, 5, open_access_url: 'example.com'
    create_list :publication, 5, scholarsphere_open_access_url: 'scholarsphere.edu'
    create_list :publication, 5, user_submitted_open_access_url: 'user_example.com'
    create_list :publication, 5, user_submitted_open_access_url: 'user_example.com', open_access_url: 'example.com'
    create_list :publication, 5, scholarsphere_open_access_url: 'scholarsphere.edu', open_access_url: 'example.com'
    create_list :publication, 5, user_submitted_open_access_url: 'user_example.com',
                                 scholarsphere_open_access_url: 'scholarsphere.edu'
    create_list :publication, 5, user_submitted_open_access_url: 'user_example.com',
                                 scholarsphere_open_access_url: 'scholarsphere.edu',
                                 open_access_url: 'example.com'
  end

  describe '#call' do
    it 'creates OpenAccessLocation records from Publication open access url data' do
      expect { described_class.call }.to change(OpenAccessLocation, :count).by 60
    end

    it 'creates OpenAccessLocation records with proper attributes' do
      oa_url_pub = create :publication, open_access_url: 'oa_url.com'
      ss_oa_url_pub = create :publication, scholarsphere_open_access_url: 'ss_oa_url.edu'
      user_oa_url_pub = create :publication, user_submitted_open_access_url: 'user_oa_url.com'

      described_class.call
      expect(OpenAccessLocation.find_by(url: oa_url_pub.read_attribute(:open_access_url)).source).to eq Source::OPEN_ACCESS_BUTTON
      expect(OpenAccessLocation.find_by(url: oa_url_pub.read_attribute(:open_access_url)).publication_id).to eq oa_url_pub.id
      expect(OpenAccessLocation.find_by(url: ss_oa_url_pub.read_attribute(:scholarsphere_open_access_url)).source).to eq Source::SCHOLARSPHERE
      expect(OpenAccessLocation.find_by(url: ss_oa_url_pub.read_attribute(:scholarsphere_open_access_url)).publication_id).to eq ss_oa_url_pub.id
      expect(OpenAccessLocation.find_by(url: user_oa_url_pub.read_attribute(:user_submitted_open_access_url)).source).to eq Source::USER
      expect(OpenAccessLocation.find_by(url: user_oa_url_pub.read_attribute(:user_submitted_open_access_url)).publication_id).to eq user_oa_url_pub.id
    end

    it 'is idempotent' do
      described_class.call
      expect { described_class.call }.not_to change(OpenAccessLocation, :count)
    end
  end
end
