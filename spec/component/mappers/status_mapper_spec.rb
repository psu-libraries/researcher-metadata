require 'component/component_spec_helper'

describe StatusMapper do
  describe '#map' do
    it "returns 'Published' when given 'Published' or 'published'" do
      expect(described_class.map('published')).to eq 'Published'
      expect(described_class.map('Published')).to eq 'Published'
    end

    it "returns 'In Press' when given 'In press', 'In Press', and 'Accepted/In press'" do
      expect(described_class.map('In press')).to eq 'In Press'
      expect(described_class.map('In Press')).to eq 'In Press'
      expect(described_class.map('Accepted/In press')).to eq 'In Press'
    end

    it "returns the original status as a string if that string doesn't map to 'In Press' or 'Published'" do
      expect(described_class.map('Some other status')).to eq 'Some other status'
      expect(described_class.map(nil)).to eq ''
      expect(described_class.map('')).to eq ''
    end
  end
end
