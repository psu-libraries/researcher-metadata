require 'component/component_spec_helper'

describe 'the contributors_table', type: :model do
  subject { Contributor.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:position).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_foreign_key(:publication_id) }
  it { is_expected.to have_db_index(:publication_id) }
end

describe Contributor, type: :model do
  subject(:contributor) { Contributor.new }

  it { is_expected.to validate_presence_of :publication }
  it { is_expected.to validate_presence_of :position }

  it { is_expected.to belong_to(:publication).inverse_of(:contributors) }

  describe "Validating that a contributor has at least one name" do
    let(:contributor) { Contributor.new(publication: create(:publication),
                                        position: 1,
                                        first_name: fn,
                                        middle_name: mn,
                                        last_name: ln) }
    let(:fn) { nil }
    let(:mn) { nil }
    let(:ln) { nil }
    context "when only the contributor's first name is present" do
      let(:fn) { 'first' }
      it "is valid" do
        expect(contributor.valid?).to eq true
      end
    end
    context "when only the contributor's middle name is present" do
      let(:mn) { 'middle' }
      it "is valid" do
        expect(contributor.valid?).to eq true
      end
    end
    context "when only the contributor's last name is present" do
      let(:ln) { 'last' }
      it "is valid" do
        expect(contributor.valid?).to eq true
      end
    end
    context "when all of the contributor's names are nil" do
      it "is invalid" do
        expect(contributor.valid?).to eq false
        expect(contributor.errors[:base]).to include "At least one name must be present."
      end
    end
    context "when all of the contributor's names are empty strings" do
      let(:fn) { '' }
      let(:mn) { '' }
      let(:ln) { '' }
      it "is invalid" do
        expect(contributor.valid?).to eq false
        expect(contributor.errors[:base]).to include "At least one name must be present."
      end
    end
    context "when all of the contributor's names are blank strings" do
      let(:fn) { ' ' }
      let(:mn) { ' ' }
      let(:ln) { ' ' }
      it "is invalid" do
        expect(contributor.valid?).to eq false
        expect(contributor.errors[:base]).to include "At least one name must be present."
      end
    end
  end

  describe '#name' do
    context "when the first, middle, and last names of the contributor are nil" do
      it "returns an empty string" do
        expect(contributor.name).to eq ''
      end
    end
    context "when the contributor has a first name" do
      before { contributor.first_name = 'first' }
      context "when the contributor has a middle name" do
        before { contributor.middle_name = 'middle' }
        context "when the contributor has a last name" do
          before { contributor.last_name = 'last' }
          it "returns the full name of the contributor" do
            expect(contributor.name).to eq 'first middle last'
          end
        end
        context "when the contributor has no last name" do
          before { contributor.last_name = '' }
          it "returns the full name of the contributor" do
            expect(contributor.name).to eq 'first middle'
          end
        end
      end
      context "when the contributor has no middle name" do
        before { contributor.middle_name = '' }
        context "when the contributor has a last name" do
          before { contributor.last_name = 'last' }
          it "returns the full name of the contributor" do
            expect(contributor.name).to eq 'first last'
          end
        end
        context "when the contributor has no last name" do
          before { contributor.last_name = '' }
          it "returns the full name of the contributor" do
            expect(contributor.name).to eq 'first'
          end
        end
      end
    end
    context "when the contributor has no first name" do
      before { contributor.first_name = '' }
      context "when the contributor has a middle name" do
        before { contributor.middle_name = 'middle' }
        context "when the contributor has a last name" do
          before { contributor.last_name = 'last' }
          it "returns the full name of the contributor" do
            expect(contributor.name).to eq 'middle last'
          end
        end
        context "when the contributor has no last name" do
          before { contributor.last_name = '' }
          it "returns the full name of the contributor" do
            expect(contributor.name).to eq 'middle'
          end
        end
      end
      context "when the contributor has no middle name" do
        before { contributor.middle_name = '' }
        context "when the contributor has a last name" do
          before { contributor.last_name = 'last' }
          it "returns the full name of the contributor" do
            expect(contributor.name).to eq 'last'
          end
        end
        context "when the contributor has no last name" do
          before { contributor.last_name = '' }
          it "returns an empty string" do
            expect(contributor.name).to eq ''
          end
        end
      end
    end
  end
end