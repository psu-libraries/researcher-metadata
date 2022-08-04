# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/models/preferred_journal_info_policy'

describe PreferredJournalInfoPolicy do
  let(:policy) { described_class.new(pub) }
  let(:pub) { double 'publication',
                     journal_title: title,
                     publisher_name: name,
                     journal: journal,
                     publisher: publisher }

  let(:title) { nil }
  let(:name) { nil }
  let(:journal) { nil }
  let(:publisher) { nil }

  describe '#journal_title' do
    context 'when the publication has a value for journal_title' do
      let(:title) { 'Title One' }

      context 'when the publication has an associated journal record' do
        let(:journal) { double 'journal', title: jt }

        context 'when the associated journal record has a blank title' do
          let(:jt) { '' }

          it 'returns the journal_title value' do
            expect(policy.journal_title).to eq 'Title One'
          end
        end

        context 'when the associated journal record has a title' do
          let(:jt) { 'Title Two' }

          it 'returns the title of the associated journal record' do
            expect(policy.journal_title).to eq 'Title Two'
          end
        end
      end

      context 'when the publication does not have an associated journal record' do
        it 'returns the value for journal_title' do
          expect(policy.journal_title).to eq 'Title One'
        end
      end
    end

    context 'when the publication has a blank journal_title' do
      let(:title) { '' }

      context 'when the publication has an associated journal record' do
        let(:journal) { double 'journal', title: jt }

        context 'when the associated journal record has a blank title' do
          let(:jt) { '' }

          it 'returns nil' do
            expect(policy.journal_title).to be_nil
          end
        end

        context 'when the associated journal record has a title' do
          let(:jt) { 'Title Two' }

          it 'returns the title of the associated journal record' do
            expect(policy.journal_title).to eq 'Title Two'
          end
        end
      end

      context 'when the publication does not have an associated journal record' do
        it 'returns nil' do
          expect(policy.journal_title).to be_nil
        end
      end
    end

    context 'when the publication does not have a value for journal_title' do
      context 'when the publication has an associated journal record' do
        let(:journal) { double 'journal', title: jt }

        context 'when the associated journal record has a blank title' do
          let(:jt) { '' }

          it 'returns nil' do
            expect(policy.journal_title).to be_nil
          end
        end

        context 'when the associated journal record has a title' do
          let(:jt) { 'Title Two' }

          it 'returns the title of the associated journal record' do
            expect(policy.journal_title).to eq 'Title Two'
          end
        end
      end

      context 'when the publication does not have an associated journal record' do
        it 'returns nil' do
          expect(policy.journal_title).to be_nil
        end
      end
    end
  end

  describe '#publisher_name' do
    context 'when the publication has a value for publisher_name' do
      let(:name) { 'Name One' }

      context 'when the publication has an associated publisher record' do
        let(:publisher) { double 'publisher', name: pn }

        context 'when the associated publisher record has a blank name' do
          let(:pn) { '' }

          it 'returns the publisher_name value' do
            expect(policy.publisher_name).to eq 'Name One'
          end
        end

        context 'when the associated publisher record has a name' do
          let(:pn) { 'Name Two' }

          it 'returns the name of the associated publisher record' do
            expect(policy.publisher_name).to eq 'Name Two'
          end
        end
      end

      context 'when the publication does not have an associated publisher record' do
        it 'returns the value for publisher_name' do
          expect(policy.publisher_name).to eq 'Name One'
        end
      end
    end

    context 'when the publication has a blank publisher_name' do
      let(:name) { '' }

      context 'when the publication has an associated publisher record' do
        let(:publisher) { double 'publisher', name: pn }

        context 'when the associated publisher record has a blank name' do
          let(:pn) { '' }

          it 'returns nil' do
            expect(policy.publisher_name).to be_nil
          end
        end

        context 'when the associated publisher record has a name' do
          let(:pn) { 'Name Two' }

          it 'returns the name of the associated publisher record' do
            expect(policy.publisher_name).to eq 'Name Two'
          end
        end
      end

      context 'when the publication does not have an associated publisher record' do
        it 'returns nil' do
          expect(policy.publisher_name).to be_nil
        end
      end
    end

    context 'when the publication does not have a value for publisher_name' do
      context 'when the publication has an associated publisher record' do
        let(:publisher) { double 'publisher', name: pn }

        context 'when the associated publisher record has a blank name' do
          let(:pn) { '' }

          it 'returns nil' do
            expect(policy.publisher_name).to be_nil
          end
        end

        context 'when the associated publisher record has a name' do
          let(:pn) { 'Name Two' }

          it 'returns the name of the associated publisher record' do
            expect(policy.publisher_name).to eq 'Name Two'
          end
        end
      end

      context 'when the publication does not have an associated publisher record' do
        it 'returns nil' do
          expect(policy.publisher_name).to be_nil
        end
      end
    end
  end
end
