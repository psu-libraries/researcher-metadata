require 'component/component_spec_helper'

describe API::V1::UserQuery do
  let(:user) { create :user }
  let(:uq) { API::V1::UserQuery.new(user) }

  describe '#contracts' do
    context "when the given user has no contracts" do
      it "returns an empty array" do
        expect(uq.contracts({})).to eq []
      end
    end

    context "when the given user has contracts" do
      let(:invis_con) { create :contract, visible: false }
      let(:vis_con) { create :contract, visible: true }
      before { user.contracts << [invis_con, vis_con] }

      it "returns on the user's visible contracts" do
        expect(uq.contracts({})).to eq [vis_con]
      end
    end
  end
end
