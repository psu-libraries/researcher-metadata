# frozen_string_literal: true

require 'component/component_spec_helper'

describe UnpaywallResponse do
  let(:response) { described_class.new(json) }
  let(:json) { JSON.parse(Rails.root.join('spec', 'fixtures', 'unpaywall1.json').read) }

  describe '#doi' do
    it 'returns doi' do
      expect(response.doi).to eq '10.1103/physrevlett.80.3915'
    end
  end

  describe '#doi_url' do
    it 'returns doi url' do
      expect(response.doi_url).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
    end
  end

  describe '#title' do
    context 'when a title is present' do
      it 'returns title' do
        expect(response.title).to eq 'Stable Characteristic Evolution of Generic Three-Dimensional Single-Black-Hole Spacetimes'
      end
    end

    context 'when the response is empty' do
      let(:json) { '' }

      it 'returns an empty string' do
        expect(response.title).to eq ''
      end
    end
  end

  describe '#genre' do
    it 'returns genre' do
      expect(response.genre).to eq 'journal-article'
    end
  end

  describe '#is_paratext' do
    it 'returns is_paratext' do
      expect(response.is_paratext).to be false
    end
  end

  describe '#published_date' do
    it 'returns published_date' do
      expect(response.published_date).to eq '1998-05-04'
    end
  end

  describe '#year' do
    it 'returns year' do
      expect(response.year).to eq 1998
    end
  end

  describe '#journal_name' do
    it 'returns journal_name' do
      expect(response.journal_name).to eq 'Physical Review Letters'
    end
  end

  describe '#journal_issns' do
    it 'returns journal_issns' do
      expect(response.journal_issns).to eq '0031-9007,1079-7114'
    end
  end

  describe '#journal_issn_l' do
    it 'returns journal_issn_l' do
      expect(response.journal_issn_l).to eq '0031-9007'
    end
  end

  describe '#journal_is_oa' do
    it 'returns journal_is_oa' do
      expect(response.journal_is_oa).to be false
    end
  end

  describe '#journal_is_in_doaj' do
    it 'returns journal_is_in_doaj' do
      expect(response.journal_is_in_doaj).to be false
    end
  end

  describe '#publisher' do
    it 'returns publisher' do
      expect(response.publisher).to eq 'American Physical Society (APS)'
    end
  end

  describe '#is_oa' do
    it 'returns is_oa' do
      expect(response.is_oa).to be true
    end
  end

  describe '#oa_status' do
    it 'returns oa_status' do
      expect(response.oa_status).to eq 'green'
    end
  end

  describe '#has_repository_copy' do
    it 'returns has_repository_copy' do
      expect(response.has_repository_copy).to be true
    end
  end

  describe '#best_oa_location' do
    let(:best) { {
      'endpoint_id' => 'arXiv.org',
      'evidence' => 'oa repository (via OAI-PMH doi match)',
      'host_type' => 'repository',
      'is_best' => true,
      'license' => nil,
      'oa_date' => nil,
      'pmh_id' => 'oai:arXiv.org:gr-qc/9801069',
      'repository_institution' => 'arXiv.org',
      'updated' => '2017-10-20T16:41:23.656642',
      'url' => 'http://arxiv.org/pdf/gr-qc/9801069',
      'url_for_landing_page' => 'http://arxiv.org/abs/gr-qc/9801069',
      'url_for_pdf' => 'http://arxiv.org/pdf/gr-qc/9801069',
      'version' => 'submittedVersion'
    }}

    it 'returns best_oa_location' do
      expect(response.best_oa_location).to eq best
    end
  end

  describe '#first_oa_location' do
    let(:first) { {
      'endpoint_id' => 'e7ba69c09103a700c9d',
      'evidence' => 'oa repository (via OAI-PMH title and first author match)',
      'host_type' => 'repository',
      'is_best' => false,
      'license' => nil,
      'oa_date' => '2021-08-05',
      'pmh_id' => 'cdr.lib.unc.edu:n583z396h',
      'repository_institution' => 'University of North Carolina at Chapel Hill - Carolina Digital Repository',
      'updated' => '2022-03-03T01:51:21.308943',
      'url' => 'https://cdr.lib.unc.edu/downloads/hm50v1675',
      'url_for_landing_page' => 'https://doi.org/10.17615/qyzk-xf22',
      'url_for_pdf' => 'https://cdr.lib.unc.edu/downloads/hm50v1675',
      'version' => 'submittedVersion'
    }}

    it 'returns first_oa_location' do
      expect(response.first_oa_location).to eq first
    end
  end

  describe '#oa_locations_json' do
    let(:locations) { [{
      'endpoint_id' => 'arXiv.org',
      'evidence' => 'oa repository (via OAI-PMH doi match)',
      'host_type' => 'repository',
      'is_best' => true,
      'license' => nil,
      'oa_date' => nil,
      'pmh_id' => 'oai:arXiv.org:gr-qc/9801069',
      'repository_institution' => 'arXiv.org',
      'updated' => '2017-10-20T16:41:23.656642',
      'url' => 'http://arxiv.org/pdf/gr-qc/9801069',
      'url_for_landing_page' => 'http://arxiv.org/abs/gr-qc/9801069',
      'url_for_pdf' => 'http://arxiv.org/pdf/gr-qc/9801069',
      'version' => 'submittedVersion'
    },
                       {
                         'endpoint_id' => 'e7ba69c09103a700c9d',
                         'evidence' => 'oa repository (via OAI-PMH title and first author match)',
                         'host_type' => 'repository',
                         'is_best' => false,
                         'license' => nil,
                         'oa_date' => '2021-08-05',
                         'pmh_id' => 'cdr.lib.unc.edu:n583z396h',
                         'repository_institution' => 'University of North Carolina at Chapel Hill - Carolina Digital Repository',
                         'updated' => '2022-03-03T01:51:21.308943',
                         'url' => 'https://cdr.lib.unc.edu/downloads/hm50v1675',
                         'url_for_landing_page' => 'https://doi.org/10.17615/qyzk-xf22',
                         'url_for_pdf' => 'https://cdr.lib.unc.edu/downloads/hm50v1675',
                         'version' => 'submittedVersion'
                       }]
    }

    it 'returns oa_locations_json' do
      expect(response.oa_locations_json).to eq locations
    end
  end

  describe '#oa_locations' do
    context 'when there are no oa locations' do
      let(:json) { { 'doi' => '10.1016/s0962-1849(05)80014-9',
                     'doi_url' => 'https://doi.org/10.1016/s0962-1849(05)80014-9',
                     'title' => 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford',
                     'oa_locations' => [] }}
      let(:response) { described_class.new(json) }

      it 'returns an empty array' do
        expect(response.oa_locations).to eq ([])
      end
    end

    context 'when there is an oa location' do
      let(:first) { response.oa_locations.first }

      it 'returns an array of oa locations' do
        expect(response.oa_locations.length).to eq 2
        expect(first.url_for_landing_page).to eq 'http://arxiv.org/abs/gr-qc/9801069'
        expect(first.url_for_pdf).to eq 'http://arxiv.org/pdf/gr-qc/9801069'
        expect(first.host_type).to eq 'repository'
        expect(first.is_best).to be true
        expect(first.license).to be_nil
        expect(first.oa_date).to be_nil
        expect(first.updated).to eq '2017-10-20T16:41:23.656642'
        expect(first.version).to eq 'submittedVersion'
      end
    end
  end

  describe '#oal_urls' do
    context 'when there are no oa locations' do
      let(:json) { { 'doi' => '10.1016/s0962-1849(05)80014-9',
                     'doi_url' => 'https://doi.org/10.1016/s0962-1849(05)80014-9',
                     'title' => 'Psychotherapy integration and the need for better theories of change: A rejoinder to Alford',
                     'oa_locations' => [] }}
      let(:response) { described_class.new(json) }

      it 'returns an empty hash' do
        expect(response.oal_urls).to eq ({})
      end
    end

    context 'when there are oa locations' do
      it 'the keys are the oa location urls' do
        expect(response.oal_urls.keys).to eq ['http://arxiv.org/pdf/gr-qc/9801069', 'https://cdr.lib.unc.edu/downloads/hm50v1675']
      end
    end
  end

  describe '#oa_locations_embargoed' do
    it 'returns oa_locations_embargoed' do
      expect(response.oa_locations_embargoed).to eq ([])
    end
  end

  describe '#updated' do
    it 'returns updated' do
      expect(response.updated).to eq '2022-06-02T04:45:26.720108'
    end
  end

  describe '#data_standard' do
    it 'returns data_standard' do
      expect(response.data_standard).to eq 2
    end
  end

  describe '#z_authors' do
    it 'returns z_authors' do
      expect(response.z_authors).to eq [{ 'family' => 'Gómez', 'given' => 'R.', 'sequence' => 'first' }, { 'family' => 'Lehner', 'given' => 'L.', 'sequence' => 'additional' }]
    end
  end
end
