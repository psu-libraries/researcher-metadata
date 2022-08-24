# frozen_string_literal: true

require 'component/component_spec_helper'

describe PublicationMatchOnDoiPolicy do
  let(:policy) { described_class.new publication1, publication2 }
  let!(:publication1) { create :sample_publication }
  let!(:publication2) do
    Publication.create(publication1
      .attributes
      .delete_if { |key, _value| ['id', 'updated_at', 'created_at'].include?(key) })
  end

  describe '#ok_to_merge?' do
    context 'when publication1 and publication2 are exactly the same' do
      it 'returns true' do
        expect(policy.ok_to_merge?).to be true
      end
    end

    context 'when publication1 and publication2 are exactly the same and...' do
      context 'the dois for publication1 and publication2 do not match exactly' do
        before do
          publication2.update doi: 'https://doi.org/10.1000/abc123'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context 'the title for publication1 is present and publication2 is not' do
        before do
          publication2.update title: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context 'the titles for publication1 and publication2 differ only by punctuation' do
        before do
          publication2.update title: publication1.title.insert(5, '.')
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context 'the titles appended to the secondary titles for publication1 and publication2 differ only by whitespace' do
        before do
          publication2.update title: publication1.title.insert(5, '       ')
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context 'the titles appended to the secondary titles for publication1 and publication2 differ only by case' do
        before do
          publication2.update title: publication1.title.upcase
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context 'the title appended to the secondary title for publication2 is included in publication1' do
        before do
          publication1.update title: "#{publication2.title}: This is some extra detail."
          publication1.update secondary_title: ''
          publication2.update secondary_title: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context 'the titles appended to the secondary titles for publication1 and publication2 do not pass matching' do
        context 'the main title does not match' do
          before do
            publication2.update title: 'Some other title'
          end

          it 'returns false' do
            expect(policy.ok_to_merge?).to be false
          end
        end

        context 'the secondary title does not match' do
          before do
            publication2.update secondary_title: 'Some other title'
          end

          it 'returns false' do
            expect(policy.ok_to_merge?).to be false
          end
        end
      end

      context 'the journal record is present for publication1 and is not present for publication2' do
        before do
          publication1.update journal_title: ''
          publication2.journal = nil
          publication2.update journal_title: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context 'the journal_title is present for publication1 and is not present for publication2' do
        before do
          publication1.journal = nil
          publication1.update journal_title: 'Journal Title'
          publication2.journal = nil
          publication2.update journal_title: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "publication1's journal records's title matches publication2's journal_title" do
        before do
          publication1.update journal_title: ''
          publication2.journal = nil
          publication2.journal_title = publication1.journal.title
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "publication1's journal records's title does not match publication2's journal_title" do
        before do
          publication1.update journal_title: ''
          publication2.journal = nil
          publication2.update journal_title: 'Some other journal'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context "publication1's journal records's title does not match publication2's journal record's title" do
        before do
          publication1.update journal_title: ''
          publication2.journal = create :journal, title: 'Some other journal'
          publication2.update journal_title: ''
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context "publication1's journal_title does not match publication2's journal_title" do
        before do
          publication1.update journal_title: 'Journal Title'
          publication2.update journal_title: 'Other Journal Title'
          publication1.journal = nil
          publication2.journal = nil
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context "publication1's volume is present and publication2's volume is not" do
        before do
          publication2.update volume: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "publication1's volume does not match publication2's volume" do
        before do
          publication2.update volume: 'Some other volume'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context "publication1's issue is present and publication2's issue is not" do
        before do
          publication1.update issue: '3'
          publication2.update issue: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "publication1's issue does not match publication2's issue" do
        before do
          publication1.update issue: '3'
          publication2.update issue: '2'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context "publication1's edition is present and publication2's edition is not" do
        before do
          publication1.update edition: '3'
          publication2.update edition: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "publication1's edition does not match publication2's edition" do
        before do
          publication1.update edition: '3'
          publication2.update edition: '2'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context "publication1's page_range is present and publication2's page_range is not" do
        before do
          publication1.update page_range: '123'
          publication2.update page_range: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "the first number in publication1's page_range is the same as the first number in publication2's page_range" do
        before do
          publication1.update page_range: '123-321'
          publication2.update page_range: '123-+'
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "the first number in publication1's page_range is not the same as the first number in publication2's page_range" do
        before do
          publication1.update page_range: '123-321'
          publication2.update page_range: '12+'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end

      context "publication1's issn is present and publication2's issn is not" do
        before do
          publication1.update issn: '1234-4321'
          publication2.update issn: ''
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "the numbers in publication1's issn are the same as the numbers in publication2's issn" do
        before do
          publication1.update issn: '1234-4321'
          publication2.update issn: '12344321'
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "the numbers in publication1's issn are different than the numbers in publication2's issn" do
        before do
          publication1.update issn: '1234-4321'
          publication2.update issn: '5678-8765'
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "publication1's publication_type is a journal article and publication2's publication_type is a different type of journal article" do
        before do
          publication1.update publication_type: 'Journal Article'
          publication2.update publication_type: 'Academic Journal Article'
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "one of the publications' publication_type is 'Other'" do
        before do
          publication1.update publication_type: 'Other'
          publication2.update publication_type: 'Book'
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "publications' publication_types are not the same, not 'Other', and both are not journal articles" do
        before do
          publication1.update publication_type: 'Journal Article'
          publication2.update publication_type: 'Book'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end
    end
  end
end
