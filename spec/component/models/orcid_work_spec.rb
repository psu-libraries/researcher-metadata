require 'component/component_spec_helper'

describe OrcidWork do
  let(:date) { Date.yesterday }
  let(:publication) { double 'publication',
                             title: 'Test Title',
                             publication_type: 'Academic Journal Article',
                             journal_title: 'Test Journal',
                             publisher: 'Test Publisher',
                             secondary_title: 'Secondary Test Title',
                             status: 'Published',
                             volume: '1',
                             issue: '2',
                             edition: '3',
                             page_range: '4-5',
                             url: 'https://url.org',
                             isbn: nil,
                             issn: nil,
                             doi: nil,
                             abstract: 'Test Abstract',
                             authors_et_al: false,
                             published_on: date
  }
  let(:authorship) { double 'authorship',
                            user: user,
                            publication: publication,
                            author_number: 1,
                            orcid_resource_identifier: nil
  }
  let(:authorship2) { double 'authorship',
                            user: user2,
                            publication: publication,
                            author_number: 2,
                            orcid_resource_identifier: nil
  }
  let(:user) { double 'user', id: 1,
                      orcid_access_token: 'the orcid token',
                      authenticated_orcid_identifier: 'the orcid id' }
  let(:user2) { double 'user', id: 2,
                       orcid_access_token: 'another orcid token',
                       authenticated_orcid_identifier: 'another orcid id',
                       first_name: 'Test',
                       middle_name: 'Tester',
                       last_name: 'McTester'
  }
  subject(:work) { OrcidWork.new(authorship) }

  describe "#to_json" do
    context "when the given authorship has external ids" do
      before { allow(publication).to receive(:issn).and_return('12345') }
      before { allow(publication).to receive(:doi).and_return('https://doi.org') }
      before { allow(publication).to receive(:authorships).and_return([authorship]) }

      it "returns a JSON representation of an ORCID work that includes external ids" do
        expect(work.to_json).to eq ({"title":
                                         {"title":"Test Title",
                                          "subtitle":"Secondary Test Title"},
                                     "journal-title":"Test Journal",
                                     "short-description":"Test Abstract",
                                     "type":"journal-article",
                                     "publication-date":
                                         {"year":date.year,
                                          "month":date.month,
                                          "day":date.day},
                                     "url":"https://url.org",
                                     "external-ids":
                                         {"external-id":
                                              [{"external-id-type":"issn",
                                                "external-id-value":"12345",
                                                "external-id-relationship":"part-of"},
                                               {"external-id-type":"doi",
                                                "external-id-value":"https://doi.org",
                                                "external-id-relationship":"self"}]
                                         }
        }.to_json)
      end
    end

    context "when the given authorship's publication has multiple authorships" do
      before { allow(publication).to receive(:authorships).and_return([authorship, authorship2]) }

      it "returns a JSON representation of an ORCID work that includes contributors" do
        expect(work.to_json).to eq ({"title":
                                         {"title":"Test Title",
                                          "subtitle":"Secondary Test Title"},
                                     "journal-title":"Test Journal",
                                     "short-description":"Test Abstract",
                                     "type":"journal-article",
                                     "publication-date":
                                         {"year":date.year,
                                          "month":date.month,
                                          "day":date.day},
                                     "url":"https://url.org",
                                     "contributors":
                                         {"contributor":
                                              [{"contributor-orcid":
                                                    {"path":"another orcid id"},
                                                "credit-name":"Test Tester McTester"}]
                                         }
        }.to_json)
      end
    end
  end

  describe "#orcid_type" do
    it "returns 'work'" do
      expect(work.orcid_type).to eq "work"
    end
  end
end
