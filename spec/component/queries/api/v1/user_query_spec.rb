require 'component/component_spec_helper'

describe API::V1::UserQuery do
  let(:user) { create :user, show_all_contracts: show_all_contracts }
  let(:show_all_contracts) { true }
  let(:uq) { API::V1::UserQuery.new(user) }

  describe '#presentations' do
    context "when the given user has no presentations" do
      it "returns an empty array" do
        expect(uq.presentations({})).to eq []
      end
    end

    context "when the given user has presentations" do
      let(:invis_pres) { create :presentation, visible: false }
      let(:vis_pres) { create :presentation, visible: true }
      before { user.presentations << [invis_pres, vis_pres] }

      it "returns the user's visible presentations" do
        expect(uq.presentations({})).to eq [vis_pres]
      end
    end
  end

  describe '#contracts' do
    context "when the given user has no contracts" do
      it "returns an empty array" do
        expect(uq.contracts).to eq Contract.none
      end
    end

    context "when the given user has contracts" do
      context "when the given user cannot show all contracts" do
        let(:show_all_contracts) { false }

        it "returns an empty array" do
          expect(uq.contracts).to eq Contract.none
        end
      end

      context "when the given user can show all contracts" do
        let(:other_hiding_user) { create :user, show_all_contracts: false }
        let(:other_showing_user) { create :user, show_all_contracts: true }

        let(:hidden_con) { create :contract, visible: true, title: "Hidden by Other" }
        let(:shown_con) { create :contract, visible: true, title: "Shown by Other" }
        let(:invis_con) { create :contract, visible: false, title: "Invisible" }
        let(:vis_con) { create :contract, visible: true, title: "Visible" }
        before do
          user.contracts << [invis_con, vis_con, hidden_con, shown_con]
          other_hiding_user.contracts << [hidden_con]
          other_showing_user.contracts << [shown_con]
        end

        it "returns the user's visible contracts that are not hidden by any other user" do
          expect(uq.contracts).to match_array [vis_con, shown_con]
        end
      end
    end
  end
end
