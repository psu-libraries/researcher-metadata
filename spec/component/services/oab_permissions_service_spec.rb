# frozen_string_literal: true

require 'component/component_spec_helper'

describe OABPermissionsService do
  let(:service) { described_class.new(doi, version) }

  context 'when version is valid' do
    let(:version) { I18n.t('file_versions.published_version') }
    let(:doi) { '10.1231/abcd.54321' }

    context 'when a network error is raised' do
      before { allow(HttpService).to receive(:get).and_raise Net::ReadTimeout }

      it 'returns nils and defaults' do
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

      it 'returns nils and defaults' do
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
                "oa_evidence": ""
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
          expect(service.licence).to eq 'https://creativecommons.org/licenses/by/4.0/'
        end
      end

      describe '#other_version_preferred?' do
        context 'when this_version is present' do
          before { allow(service).to receive(:this_version).and_return({ 'version' => I18n.t('file_versions.accepted_version') }) }

          it 'returns false' do
            expect(service.other_version_preferred?).to be false
          end
        end

        context 'when this version is not present' do
          before { allow(service).to receive(:this_version).and_return({}) }

          context 'when accepted version is present and published version is not' do
            before do
              allow(service).to receive(:accepted_version).and_return({ 'version' => I18n.t('file_versions.accepted_version') })
              allow(service).to receive(:published_version).and_return({})
            end

            it 'returns true' do
              expect(service.other_version_preferred?).to be true
            end
          end

          context 'when published version is present and accepted version is not' do
            before do
              allow(service).to receive(:accepted_version).and_return({})
              allow(service).to receive(:published_version).and_return({ 'version' => I18n.t('file_versions.published_version') })
            end

            it 'returns true' do
              expect(service.other_version_preferred?).to be true
            end
          end

          context 'when no version is present' do
            before do
              allow(service).to receive(:accepted_version).and_return({})
              allow(service).to receive(:published_version).and_return({})
            end

            it 'returns false' do
              expect(service.other_version_preferred?).to be false
            end
          end
        end
      end
    end
  end

  context 'when version is not valid' do
    let(:version) { 'invalidVersion' }
    let(:doi) { '10.1231/abcd.54321' }

    it 'raises and error' do
      expect { service }.to raise_error OABPermissionsService::InvalidVersion
    end
  end
end
