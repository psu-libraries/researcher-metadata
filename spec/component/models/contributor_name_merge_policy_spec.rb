# frozen_string_literal: true

require 'component/component_spec_helper'

describe ContributorNameMergePolicy do
  let(:policy) { described_class.new([contributor1, contributor2]) }

  describe "#contributor_names_to_keep" do
    context "when contributors have the same first letter of their first name" do
      context "when contributors have the same last name" do
        context "when contributors have the same position" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'T', last_name: 'Tester', position: 1 }
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
              contributor2.update user_id: 1
              contributor1.update role: "Author"
            end
            it 'selects that contributor as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end

          context 'when one contributor has a role and the other does not' do
            before do
              contributor1.update role: "Author"
            end
            it 'selects that contributor as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end

          context 'when both contributors have a role but one also has a user_id' do
            before do
              contributor1.update role: "Author"
              contributor2.update role: "Author"
              contributor1.update user_id: 1
            end
            it 'selects that contributor as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end

          context 'when both contributors have a user_id, and role' do
            before do
              contributor1.update user_id: 1
              contributor2.update user_id: 1
              contributor1.update role: "Author"
              contributor2.update role: "Author"
            end
            it 'selects the contributor with a longer name as the preferred contributor' do
              expect(policy.contributor_names_to_keep.first).to eq contributor1
            end
          end
        end

        context "when contributors have different positions" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'Terry', last_name: 'Tester', position: 2 }
          it 'treats these contributors as the different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end

      context "when contributors have a different last name" do
        context "when contributors have the same position" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'Test', last_name: 'Terry', position: 1 }
          it 'treats these contributors as the different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end

        context "when contributors have different positions" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'Test', last_name: 'Terry', position: 2 }
          it 'treats these contributors as the different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end
    end

    context "when contributors have a different first letter of their first name" do
      context "when contributors have the same last name" do
        context "when contributors have the same position" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Tester', position: 1 }
          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end

        context "when contributors have different positions" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Tester', position: 2 }
          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end

      context "when contributors have a different last name" do
        context "when contributors have the same position" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Terry', position: 1 }
          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end

        context "when contributors have different positions" do
          let(:contributor1) { ContributorName.create first_name: 'Test', last_name: 'Tester', position: 1 }
          let(:contributor2) { ContributorName.create first_name: 'J', last_name: 'Terry', position: 2 }
          it 'treats these contributors as different' do
            expect(policy.contributor_names_to_keep.count).to eq 2
          end
        end
      end
    end
  end
end