require 'component/component_spec_helper'

describe API::V1::UserQuery do
  let(:user) { create :user }
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

  describe '#publications' do
    let(:user) { create :user, show_all_publications: true }

    context "when the user can show all publications" do
      context "when the user has no publications" do
        it "returns an empty array" do
          expect(uq.publications({})).to eq []
        end
      end
      context "when the user has publications" do
        let(:invis_pub) { create :publication, visible: false }
        let(:vis_pub) { create :publication, visible: true }
        before do
          create :authorship, user: user, publication: invis_pub, author_number: 1
          create :authorship, user: user, publication: vis_pub, author_number: 1
        end

        it "returns the user's visible publications" do
          expect(uq.publications({})).to eq [vis_pub]
        end
      end
    end
    context "when the user cannot show any publications" do
      let(:user) { create :user, show_all_publications: false }

      context "when the user has no publications" do
        it "returns an empty array" do
          expect(uq.publications({})).to eq []
        end
      end
      context "when the user has publications" do
        let(:invis_pub) { create :publication, visible: false }
        let(:vis_pub) { create :publication, visible: true }
        before do
          create :authorship, user: user, publication: invis_pub, author_number: 1
          create :authorship, user: user, publication: vis_pub, author_number: 1
        end

        it "returns an empty array" do
          expect(uq.publications({})).to eq []
        end
      end
    end
  end
end
