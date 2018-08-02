require 'component/component_spec_helper'

describe API::V1::PublicationSerializer do
  let(:publication) { Publication.new(title: 'publication 1') }

  describe "data attributes" do
    subject { serialized_data_attributes(publication) }
    it { is_expected.to include(:title => 'publication 1') }
  end
end
