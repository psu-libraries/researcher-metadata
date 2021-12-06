# frozen_string_literal: true

require 'component/component_spec_helper'

describe PublicationMergeOnDoiPolicy do
  let(:policy) { described_class.new publication1, publication2 }
  let!(:publication1) { create :sample_publication }
  let!(:publication2) { create :sample_publication }

  describe '#merge!' do
    describe 'title merging' do
      context 'when neither publication was imported from Pure' do
        before do
          publication1.update title: 'Short'
          publication1.update secondary_title: 'Title'
        end

        it 'picks the longer title' do
          policy.merge!
          expect(publication1.reload.title).to eq publication2.title
        end
      end

      context 'when one publication was imported from Pure' do
        before do
          create :publication_import, :from_pure, publication: publication2
          publication2.save
        end

        context 'when secondary title is present in the imported from Pure publication' do
          context 'when secondary title is not within the main title' do
            it 'appends secondary title to main title of the imported from Pure publication and picks this as the title' do
              policy.merge!
              expect(publication1.reload.title).to eq "#{publication2.title}: #{publication2.secondary_title}"
            end
          end

          context 'when secondary title is within the main title' do
            before do
              publication2.update title: "#{publication2.title}: #{publication2.secondary_title}"
            end

            it 'picks the title from the imported from Pure record' do
              policy.merge!
              expect(publication1.reload.title).to eq publication2.title
            end
          end
        end

        context 'when secondary title is not present in the imported from Pure record' do
          before do
            publication2.update secondary_title: ''
          end

          it 'picks the title from the imported from Pure record' do
            policy.merge!
            expect(publication1.reload.title).to eq publication2.title
          end
        end
      end
    end

    describe 'secondary_title merging' do
      context 'when one or both publications were imported from Pure' do
        before do
          create :publication_import, :from_pure, publication: publication2
          publication2.save
        end

        it 'sets secondary_title to nil' do
          policy.merge!
          expect(publication1.reload.secondary_title).to eq nil
        end
      end

      context 'when neither publication was imported from Pure' do
        context 'when only one publication has a secondary title and it is not within the main title' do
          before do
            publication1.update secondary_title: ''
          end

          it 'picks this secondary title' do
            policy.merge!
            expect(publication1.reload.secondary_title).to eq publication2.secondary_title
          end
        end

        context 'when only one publication has a secondary title and it is within the main title' do
          before do
            publication1.update secondary_title: ''
            publication1.update title: 'Short title'
            publication2.update title: "Title#{publication2.secondary_title}"
          end

          it 'sets secondary_title to nil' do
            policy.merge!
            expect(publication1.reload.secondary_title).to eq nil
          end
        end

        context 'when both publications have a secondary title that is not within the main title' do
          it 'picks the secondary title from the first publication' do
            secondary_title = publication1.secondary_title
            policy.merge!
            expect(publication1.reload.secondary_title).to eq secondary_title
          end
        end
      end
    end

    describe 'journal merging' do
      context 'when only one journal is present' do
        before do
          publication2.journal = nil
          publication2.save
        end

        it 'picks this journal' do
          journal = publication1.journal
          policy.merge!
          expect(publication1.reload.journal).to eq journal
        end
      end

      context 'when both journals are present (they should be the same)' do
        it 'picks this journal' do
          policy.merge!
          expect(publication1.reload.journal).to eq publication2.journal
        end
      end
    end

    describe 'journal_title merging' do
      before do
        publication2.update journal_title: 'Journal Title'
      end

      context 'when a journal has been selected for the merge' do
        it 'sets journal_title to nil' do
          policy.merge!
          expect(publication1.reload.journal_title).to eq nil
        end
      end

      context 'when a journal has not been selected for the merge' do
        before do
          publication1.journal = nil
          publication2.journal = nil
          publication1.save
          publication2.save
        end

        it 'selects the journal_title' do
          policy.merge!
          expect(publication1.reload.journal_title).to eq 'Journal Title'
        end
      end
    end

    describe 'publisher_name merging' do
      before do
        publication2.update publisher_name: 'Publisher Name'
      end

      context 'when a journal has been selected for the merge' do
        it 'sets publisher_name to nil' do
          policy.merge!
          expect(publication1.reload.publisher_name).to eq nil
        end
      end

      context 'when a journal has not been selected for the merge' do
        before do
          publication1.journal = nil
          publication2.journal = nil
          publication1.save
          publication2.save
        end

        it 'selects the publisher_name' do
          policy.merge!
          expect(publication1.reload.publisher_name).to eq 'Publisher Name'
        end
      end
    end

    describe 'published_on merging' do
      before do
        publication1.update published_on: Date.today
        publication2.update published_on: (Date.today - 1.year)
      end

      it 'selects the most distant date' do
        policy.merge!
        expect(publication1.reload.published_on).to eq publication2.published_on
      end
    end

    describe 'status merging' do
      context 'when both statuses are published' do
        before do
          publication1.update status: Publication::PUBLISHED_STATUS
          publication2.update status: Publication::PUBLISHED_STATUS
        end

        it 'chooses published' do
          policy.merge!
          expect(publication1.reload.status).to eq Publication::PUBLISHED_STATUS
        end
      end

      context 'when both statuses are in press' do
        before do
          publication1.update status: Publication::IN_PRESS_STATUS
          publication2.update status: Publication::IN_PRESS_STATUS
        end

        it 'chooses in press' do
          policy.merge!
          expect(publication1.reload.status).to eq Publication::IN_PRESS_STATUS
        end
      end

      context 'when one status is in press and the other is published' do
        before do
          publication1.update status: Publication::IN_PRESS_STATUS
          publication2.update status: Publication::PUBLISHED_STATUS
        end

        it 'chooses published' do
          policy.merge!
          expect(publication1.reload.status).to eq Publication::PUBLISHED_STATUS
        end
      end
    end

    describe 'volume merging' do
      context 'when only one volume is present' do
        before do
          publication1.update volume: nil
          publication2.update volume: '3'
        end

        it 'picks this volume' do
          policy.merge!
          expect(publication1.reload.volume).to eq publication2.volume
        end
      end

      context 'when both volumes are present (they should be the same)' do
        before do
          publication1.update volume: '3'
          publication2.update volume: '3'
        end

        it 'picks this volume' do
          volume = publication1.volume
          policy.merge!
          expect(publication1.reload.volume).to eq volume
        end
      end
    end

    describe 'issue merging' do
      context 'when only one issue is present' do
        before do
          publication1.update issue: nil
          publication2.update issue: '3'
        end

        it 'picks this issue' do
          policy.merge!
          expect(publication1.reload.issue).to eq publication2.issue
        end
      end

      context 'when both issues are present (they should be the same)' do
        before do
          publication1.update issue: '3'
          publication2.update issue: '3'
        end

        it 'picks this issue' do
          issue = publication1.issue
          policy.merge!
          expect(publication1.reload.issue).to eq issue
        end
      end
    end

    describe 'edition merging' do
      context 'when only one edition is present' do
        before do
          publication1.update edition: nil
          publication2.update edition: '3'
        end

        it 'picks this edition' do
          policy.merge!
          expect(publication1.reload.edition).to eq publication2.edition
        end
      end

      context 'when both editions are present (they should be the same)' do
        before do
          publication1.update edition: '3'
          publication2.update edition: '3'
        end

        it 'picks this edition' do
          edition = publication1.edition
          policy.merge!
          expect(publication1.reload.edition).to eq edition
        end
      end
    end

    describe 'page_range merging' do
      context 'when only one page_range is present' do
        before do
          publication1.update page_range: nil
          publication2.update page_range: '123-321'
        end

        it 'picks this page_range' do
          policy.merge!
          expect(publication1.reload.page_range).to eq publication2.page_range
        end
      end

      context 'when both page_ranges are present' do
        before do
          publication1.update page_range: '123'
          publication2.update page_range: '123-321'
        end

        it 'picks the longer page_range' do
          policy.merge!
          expect(publication1.reload.page_range).to eq publication2.page_range
        end
      end
    end

    describe 'url merging' do
      context 'when only one url is present' do
        before do
          publication1.update url: nil
          publication2.update url: 'url.com'
        end

        it 'picks this url' do
          policy.merge!
          expect(publication1.reload.url).to eq publication2.url
        end
      end

      context 'when both urls are present' do
        before do
          publication1.update url: 'url.com'
          publication2.update url: 'url2.com'
        end

        it 'picks either url' do
          policy.merge!
          expect(publication1.reload.url).to match /url.com|url2.com/
        end
      end
    end

    describe 'issn merging' do
      context 'when only one issn is present' do
        context 'when hyphen is not present' do
          before do
            publication1.update issn: nil
            publication2.update issn: '12345678'
          end

          it 'picks this issn and adds hyphen' do
            policy.merge!
            expect(publication1.reload.issn).to eq '1234-5678'
          end
        end

        context 'when hyphen is present' do
          before do
            publication1.update issn: nil
            publication2.update issn: '1234-5678'
          end

          it 'picks this issn' do
            policy.merge!
            expect(publication1.reload.issn).to eq '1234-5678'
          end
        end

        context 'when extra wording is present' do
          before do
            publication1.update issn: nil
            publication2.update issn: 'ISSN: 1234-5678'
          end

          it 'picks this issn and removes wording' do
            policy.merge!
            expect(publication1.reload.issn).to eq '1234-5678'
          end
        end

        context 'when more than one issn is present in the issn field' do
          before do
            publication1.update issn: nil
            publication2.update issn: 'ISSN: 1234-5678(print) ISSN: 4567-789X(electronic)'
          end

          it 'picks this issn and picks first issn' do
            policy.merge!
            expect(publication1.reload.issn).to eq '1234-5678'
          end
        end
      end

      context 'when both issns are present' do
        before do
          publication1.update issn: 'ISSN: 9876-5432(electronic) ISSN: 1234-5678(print)'
          publication2.update issn: '12345678'
        end

        it 'picks the shorter issn and formats it properly' do
          policy.merge!
          expect(publication1.reload.issn).to eq '1234-5678'
        end
      end
    end

    describe 'isbn merging' do
      context 'when only one isbn is present' do
        before do
          publication1.update isbn: nil
          publication2.update isbn: 'abcd1234efg5678'
        end

        it 'picks this isbn' do
          policy.merge!
          expect(publication1.reload.isbn).to eq publication2.isbn
        end
      end

      context 'when both isbns are present' do
        before do
          publication1.update isbn: 'abcd1234efg5678'
          publication2.update isbn: '1234efg5678abcd'
        end

        it 'picks either isbn' do
          policy.merge!
          expect(publication1.reload.isbn).to match /abcd1234efg5678|1234efg5678abcd/
        end
      end
    end

    describe 'publication_type merging' do
      context "when one of the publication types is 'Other'" do
        before do
          publication1.update publication_type: 'Other'
          publication2.update publication_type: 'Book'
        end

        it "picks the publication_type that is not 'Other'" do
          policy.merge!
          expect(publication1.reload.publication_type).to eq publication2.publication_type
        end
      end

      context "when none of the publication types is 'Other'" do
        before do
          publication1.update publication_type: 'Journal Article'
          publication2.update publication_type: 'Academic Journal Article'
        end

        it 'picks the publication_type that is longer' do
          policy.merge!
          expect(publication1.reload.publication_type).to eq publication2.publication_type
        end
      end
    end

    describe 'abstract merging' do
      context 'when only one abstract is present' do
        before do
          publication1.update abstract: nil
          publication2.update abstract: 'This is an abstract.'
        end

        it 'picks this abstract' do
          policy.merge!
          expect(publication1.reload.abstract).to eq publication2.abstract
        end
      end

      context 'when both abstracts are present' do
        before do
          publication1.update abstract: 'This is an abstract'
          publication2.update abstract: 'This is an abstract.'
        end

        it 'picks the longer abstract' do
          policy.merge!
          expect(publication1.reload.abstract).to eq publication2.abstract
        end
      end
    end

    describe 'authors_et_al merging' do
      context 'when one authors_et_all is true' do
        before do
          publication1.update authors_et_al: false
          publication2.update authors_et_al: true
        end

        it 'picks true' do
          policy.merge!
          expect(publication1.reload.authors_et_al).to eq true
        end
      end

      context 'when both authors_et_all are true' do
        before do
          publication1.update authors_et_al: true
          publication2.update authors_et_al: true
        end

        it 'picks true' do
          policy.merge!
          expect(publication1.reload.authors_et_al).to eq true
        end
      end

      context 'when both authors_et_all are false' do
        before do
          publication1.update authors_et_al: false
          publication2.update authors_et_al: false
        end

        it 'picks false' do
          policy.merge!
          expect(publication1.reload.authors_et_al).to eq false
        end
      end
    end

    describe 'total_scopus_citation merging' do
      context 'when only one total_scopus_citations is present' do
        before do
          publication1.update total_scopus_citations: nil
          publication2.update total_scopus_citations: 5
        end

        it 'picks this total_scopus_citations' do
          policy.merge!
          expect(publication1.reload.total_scopus_citations).to eq publication2.total_scopus_citations
        end
      end

      context 'when both total_scopus_citations are present' do
        before do
          publication1.update total_scopus_citations: 5
          publication2.update total_scopus_citations: 6
        end

        it 'picks either total_scopus_citations' do
          policy.merge!
          expect(publication1.reload.total_scopus_citations.to_s).to match /5|6/
        end
      end
    end
  end
end
