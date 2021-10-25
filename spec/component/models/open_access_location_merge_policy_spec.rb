# frozen_string_literal: true

require 'component/component_spec_helper'

describe OpenAccessLocationMergePolicy do
  let!(:publication1) { create :publication }
  let!(:publication2) { create :publication }
  let!(:publication3) { create :publication }
  let!(:open_access_location1) do
    create :open_access_location,
           url: 'example.edu',
           source: 'User',
           publication_id: publication1.id
  end
  let!(:open_access_location2) do
    create :open_access_location,
           url: 'example.edu',
           source: 'Open Access Button',
           publication_id: publication2.id
  end
  let!(:open_access_location3) do
    create :open_access_location,
           url: 'example.edu',
           source: 'User',
           publication_id: publication3.id
  end
  let!(:open_access_location4) do
    create :open_access_location,
           url: 'scholarsphere.edu',
           source: 'ScholarSphere',
           publication_id: publication1.id
  end
  let!(:open_access_location5) do
    create :open_access_location,
           url: 'scholarsphere.edu',
           source: 'ScholarSphere',
           publication_id: publication2.id
  end
  let!(:open_access_location6) do
    create :open_access_location,
           url: 'scholarsphere.edu',
           source: 'Unpaywall',
           publication_id: publication3.id
  end
  let!(:open_access_location7) do
    create :open_access_location,
           url: 'site.edu',
           source: 'Unpaywall',
           publication_id: publication3.id
  end

  describe '#open_access_lcoations_to_keep' do
    it 'returns an array of unique open access locations from a group of publications' do
      expect(described_class.new([publication1,
                                  publication2,
                                  publication3]).open_access_locations_to_keep).to eq [open_access_location1,
                                                                                       open_access_location4,
                                                                                       open_access_location2,
                                                                                       open_access_location6,
                                                                                       open_access_location7]
    end
  end
end