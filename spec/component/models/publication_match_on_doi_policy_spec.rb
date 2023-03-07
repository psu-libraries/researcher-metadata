# frozen_string_literal: true

require 'component/component_spec_helper'

describe PublicationMatchOnDOIPolicy do
  let(:policy) { described_class.new publication1, publication2 }
  let!(:publication1) { create(:sample_publication) }
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

      context 'the title appended to the secondary title for publication2 is at least a 60% match to the title for publication1' do
        before do
          publication2.update title: 'A lengthy but overall fairly generic main title that is greater than 60%'
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
            publication2.update title: 'Some other title that is different from title1'
          end

          it 'returns false' do
            expect(policy.ok_to_merge?).to be false
          end
        end

        context 'the secondary title does not match' do
          before do
            publication2.update secondary_title: 'Some other secondary title that is significantly different and creates more than a 40% difference'
          end

          it 'returns false' do
            expect(policy.ok_to_merge?).to be false
          end
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

      context "publications' publication_type are both from merge_allowed? list" do
        before do
          publication1.update publication_type: 'Journal Article'
          publication2.update publication_type: 'Editorial'
        end

        it 'returns true' do
          expect(policy.ok_to_merge?).to be true
        end
      end

      context "one publication's publication_type is from the merge_allowed? list but the other is not" do
        before do
          publication1.update publication_type: 'Journal Article'
          publication2.update publication_type: 'Manuscript'
        end

        it 'returns false' do
          expect(policy.ok_to_merge?).to be false
        end
      end
    end
  end
end
