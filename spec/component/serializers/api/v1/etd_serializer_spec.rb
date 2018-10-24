require 'component/component_spec_helper'

describe API::V1::ETDSerializer do
  let(:etd) {
    create :etd,
    title: 'etd 1',
    year: 2018,
    author_last_name: 'Developer',
    author_middle_name: 'Q',
    author_first_name: 'Joe'
  }

  describe "data attributes" do
    subject { serialized_data_attributes(etd) }
    it { is_expected.to include(:title => 'etd 1') }
    it { is_expected.to include(:year => 2018) }
    it { is_expected.to include(:author_last_name => 'Developer') }
    it { is_expected.to include(:author_middle_name => 'Q') }
    it { is_expected.to include(:author_first_name => 'Joe') }
  end
end
