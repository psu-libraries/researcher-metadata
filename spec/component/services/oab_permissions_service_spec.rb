# frozen_string_literal: true

require 'component/component_spec_helper'

describe OabPermissionsService do
  let(:service) { described_class.new(doi, version) }

  context 'when version is valid' do
    let(:version) { 'publishedVersion' }
    let(:doi) { '10.1231/abcd.54321' }

    context 'when a network error is raised' do
      before { allow(HttpService).to receive(:get).and_raise Net::ReadTimeout }

      it 'returns nils' do
        expect(service.set_statement).to be_nil
        expect(service.embargo_end_date).to be_nil
        expect(service.licence).to be_nil
      end
    end

    context 'when a JSON parsing error is raised' do
      before do
        allow(HttpService).to receive(:get).and_return('{}')
        allow(JSON).to receive(:parse).and_raise JSON::ParserError
      end

      it 'returns nils' do
        expect(service.set_statement).to be_nil
        expect(service.embargo_end_date).to be_nil
        expect(service.licence).to be_nil
      end
    end

    context 'when no error is raised' do
      # I could not get these tests to parse the response from VCR properly
      # Just mocking the HttpService get method instead
      before do
        allow(HttpService).to receive(:get).and_return(
          '
          {
            "best_permission": {
              "can_archive": true,
              "version": "publishedVersion",
              "versions": [
                "publishedVersion"
              ],
              "licence": "cc-by",
              "locations": [
                "institutional repository"
              ],
              "embargo_months": 0,
              "issuer": {
                "type": "Journal",
                "has_policy": "yes",
                "id": [
                  "1234-1234"
                ],
                "journal_oa_type": "gold"
              },
              "meta": {
                "creator": "joe+schmoe@oa.works",
                "contributors": [
                  "joe+schmoe@oa.works"
                ],
                "monitoring": "Automatic"
              },
              "licences": [
                {
                  "type": "CC BY"
                }
              ],
              "provenance": {
                "oa_evidence": "In DOAJ"
              },
              "score": 1234
            },
            "all_permissions": [
              {
                "can_archive": true,
                "version": "publishedVersion",
                "versions": [
                  "publishedVersion"
                ],
                "licence": "cc-by",
                "locations": [
                  "institutional repository"
                ],
                "embargo_months": 24,
                "embargo_end": "2024-09-01",
                "deposit_statement": "Statement",
                "issuer": {
                  "type": "Journal",
                  "has_policy": "yes",
                  "id": [
                    "1234-1234"
                  ],
                  "journal_oa_type": "gold"
                },
                "meta": {
                  "creator": "joe+schmoe@oa.works",
                  "contributors": [
                    "joe+schmoe@oa.works"
                  ],
                  "monitoring": "Automatic"
                },
                "licences": [
                  {
                    "type": "CC BY"
                  }
                ],
                "provenance": {
                  "oa_evidence": "In DOAJ"
                },
                "score": 1234
              },
              {
                "can_archive": true,
                "version": "publishedVersion",
                "versions": [
                  "submittedVersion",
                  "acceptedVersion",
                  "publishedVersion"
                ],
                "licence": "cc-by",
                "locations": [
                  "institutional repository"
                ],
                "issuer": {
                  "type": "article",
                  "has_policy": "yes",
                  "id": "10.1234/abcd.2022.123456",
                  "journal_oa_type": "gold"
                },
                "meta": {
                  "creator": "support@unpaywall.org",
                  "contributors": [
                    "support@unpaywall.org"
                  ],
                  "monitoring": "Automatic",
                  "updated": "2022-08-09T08:10:00.177402"
                },
                "provenance": {
                  "oa_evidence": "oa journal (via joeschmoe)"
                },
                "score": 1234,
                "licences": [
                  {
                    "type": "cc-by"
                  }
                ]
              }
            ]
          }
          '
        )
      end

      describe '#set_statement' do
        it 'returns the set_statement string' do
          expect(service.set_statement).to eq 'Statement'
        end
      end

      describe '#embargo_end_date' do
        it 'returns the embargo_end_date data' do
          expect(service.embargo_end_date).to eq Date.parse('2024-09-01', '%Y-%m-%d')
        end
      end

      describe '#licence' do
        it 'returns the licence string' do
          expect(service.licence).to eq 'cc-by'
        end
      end
    end
  end

  context 'when version is not valid' do
    let(:version) { 'invalidVersion' }
    let(:doi) { '10.1231/abcd.54321' }

    it 'raises and error' do
      expect{ service }.to raise_error OabPermissionsService::InvalidVersion
    end
  end
end
