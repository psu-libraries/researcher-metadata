# frozen_string_literal: true

require 'component/component_spec_helper'

describe LicenceMapper do
  context 'when nil' do
    it 'returns nil' do
      expect(described_class.map(nil)).to be_nil
    end
  end

  context 'when cc-by' do
    it 'returns https://creativecommons.org/licenses/by/4.0/' do
      expect(described_class.map('cc-by')).to eq 'https://creativecommons.org/licenses/by/4.0/'
    end
  end

  context 'when cc-by 3.0' do
    it 'returns https://creativecommons.org/licenses/by/4.0/' do
      expect(described_class.map('cc-by 3.0')).to eq 'https://creativecommons.org/licenses/by/4.0/'
    end
  end

  context 'when CC-BY 4.0' do
    it 'returns https://creativecommons.org/licenses/by/4.0/' do
      expect(described_class.map('CC-BY 4.0')).to eq 'https://creativecommons.org/licenses/by/4.0/'
    end
  end

  context 'when cc-by-nc' do
    it 'returns https://creativecommons.org/licenses/by-nc/4.0/' do
      expect(described_class.map('cc-by-nc')).to eq 'https://creativecommons.org/licenses/by-nc/4.0/'
    end
  end

  context 'when CC-BY-NC-nd' do
    it 'returns https://creativecommons.org/licenses/by-nc-nd/4.0/' do
      expect(described_class.map('CC-BY-NC-nd')).to eq 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
    end
  end

  context 'when CC-BY-NC-SA' do
    it 'returns https://creativecommons.org/licenses/by-nc-sa/4.0/' do
      expect(described_class.map('CC-BY-NC-SA')).to eq 'https://creativecommons.org/licenses/by-nc-sa/4.0/'
    end
  end

  context 'when cc0' do
    it 'returns http://creativecommons.org/publicdomain/zero/1.0/' do
      expect(described_class.map('cc0')).to eq 'http://creativecommons.org/publicdomain/zero/1.0/'
    end
  end

  context 'when other (non-commercial)' do
    it 'returns https://rightsstatements.org/page/InC/1.0/' do
      expect(described_class.map('other (non-commercial)')).to eq 'https://rightsstatements.org/page/InC/1.0/'
    end
  end

  context 'when other-closed' do
    it 'returns https://rightsstatements.org/page/InC/1.0/' do
      expect(described_class.map('other-closed')).to eq 'https://rightsstatements.org/page/InC/1.0/'
    end
  end

  context 'when Other-closed' do
    it 'returns https://rightsstatements.org/page/InC/1.0/' do
      expect(described_class.map('Other-closed')).to eq 'https://rightsstatements.org/page/InC/1.0/'
    end
  end

  context 'when none' do
    it 'returns https://rightsstatements.org/page/InC/1.0/' do
      expect(described_class.map('none')).to eq 'https://rightsstatements.org/page/InC/1.0/'
    end
  end

  context 'when None' do
    it 'returns https://rightsstatements.org/page/InC/1.0/' do
      expect(described_class.map('None')).to eq 'https://rightsstatements.org/page/InC/1.0/'
    end
  end

  context 'when unclear' do
    it 'returns https://rightsstatements.org/page/InC/1.0/' do
      expect(described_class.map('unclear')).to eq 'https://rightsstatements.org/page/InC/1.0/'
    end
  end

  context 'when somthing else' do
    it 'returns nil' do
      expect(described_class.map('something else')).to eq nil
    end
  end
end
