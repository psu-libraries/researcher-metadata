require 'component/component_spec_helper'

describe PublicationSerializer do
  let(:publication) { create(:publication, title: 'publication 1') }

  describe "data attributes" do
    subject { serialized_data_attributes(publication) }
    it { is_expected.to include(:title => 'publication 1') }
  end
end
