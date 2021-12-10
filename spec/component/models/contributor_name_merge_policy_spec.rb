# frozen_string_literal: true

require 'component/component_spec_helper'

describe ContributorNameMergePolicy do
  let(:policy) { described_class.new([contributor1, contributor2]) }
  let!(:publication1) { FactoryBot.create :publication }
  let!(:publication2) { FactoryBot.create :publication }
  let!(:user1) { FactoryBot.create :user, id: 1 }
  let!(:user2) { FactoryBot.create :user, id: 2 }

  describe '#contributor_names_to_keep' do
    context 'when contributors have the same user_id and the user_id is not blank' do
      let(:contributor1) do
        ContributorName.create first_name: 'Test',
                               last_name: 'Tester',
                               position: 1,
                               publication: publication1,
                               user_id: 1
      end
      let(:contributor2) do
        ContributorName.create first_name: 'T',
                               last_name: 'Tester',
                               position: 1,
                               publication: publication2,
                               user_id: 1
      end

      context 'when one contributor names comes from pure' do
        let!(:import) { FactoryBot.create :publication_import, :from_pure, publication: publication1 }

        it 'keeps this record and discards the rest' do
          expect(policy.contributor_names_to_keep.count).to eq 1
          expect(policy.contributor_names_to_keep.first).to eq contributor1
        end
      end

      context 'when one contributor name comes from activity insight' do
        let!(:import) { FactoryBot.create :publication_import, :from_activity_insight, publication: publication2 }

        it 'keeps this record and discards the rest' do
          expect(policy.contributor_names_to_keep.count).to eq 1
          expect(policy.contributor_names_to_keep.first).to eq contributor2
        end
      end

      context 'when one contributor name comes from activity insight and the other from pure' do
        let!(:import1) { FactoryBot.create :publication_import, :from_pure, publication: publication1 }
        let!(:import2) { FactoryBot.create :publication_import, :from_activity_insight, publication: publication2 }

        it 'keeps the pure record and discards the rest' do
          expect(policy.contributor_names_to_keep.count).to eq 1
          expect(policy.contributor_names_to_keep.first).to eq contributor1
        end
      end

      context 'when none of the contributor names come from pure or activity insight' do
        it 'randomly selects a record' do
          expect(policy.contributor_names_to_keep.count).to eq 1
        end
      end
    end

    context 'when contributors have the same first letter of their first name' do
      context 'when contributors have the same last name' do
        context 'when contributors have the same position' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'T', last_name: 'Tester', position: 1, publication: publication2 }

          it 'treats these contributors as the same' do
            expect(policy.contributor_names_to_keep.count).to eq 1
          end

          context 'when one contributor has a user_id and the other does not' do
            before do
              contributor1.update user_id: 1
            end

            it 'selects that contributor as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end

          context 'when both contributors have a user_id but one also has a role' do
            before do
              contributor1.update user_id: 1
              contributor2.update user_id: 2
              contributor1.update role: 'Author'
            end

            it 'selects that contributor as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end

          context 'when one contributor has a role and the other does not' do
            before do
              contributor1.update role: 'Author'
            end

            it 'selects that contributor as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end

          context 'when both contributors have a role but one also has a user_id' do
            before do
              contributor1.update role: 'Author'
              contributor2.update role: 'Author'
              contributor1.update user_id: 1
            end

            it 'selects that contributor as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end

          context 'when both contributors have a user_id, and role' do
            before do
              contributor1.update user_id: 1
              contributor2.update user_id: 2
              contributor1.update role: 'Author'
              contributor2.update role: 'Author'
            end

            it 'selects the contributor with a longer name as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end
        end

        context 'when contributors have different positions' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'Terry', last_name: 'Tester', position: 2, publication: publication2 }

          it 'treats these contributors as the different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end

      context 'when contributors have a different last name' do
        context 'when contributors have the same position' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'Test', last_name: 'Terry', position: 1, publication: publication2 }

          it 'treats these contributors as the different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end

        context 'when contributors have different positions' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'Test', last_name: 'Terry', position: 2, publication: publication2 }

          it 'treats these contributors as the different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end
    end

    context 'when contributors have a different first letter of their first name' do
      context 'when contributors have the same last name' do
        context 'when contributors have the same position' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Tester', position: 1, publication: publication2 }

          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end

        context 'when contributors have different positions' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Tester', position: 2, publication: publication2 }

          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end

      context 'when contributors have a different last name' do
        context 'when contributors have the same position' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Terry', position: 1, publication: publication2 }

          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end

        context 'when contributors have different positions' do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1, publication: publication1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Terry', position: 2, publication: publication2 }

          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end
    end
  end
end
