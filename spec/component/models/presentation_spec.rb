require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the presentations table', type: :model do
  subject { Presentation.new }

  it { is_expected.to have_db_column(:title).of_type(:text) }
  it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:name).of_type(:text) }
  it { is_expected.to have_db_column(:organization).of_type(:string) }
  it { is_expected.to have_db_column(:location).of_type(:string) }
  it { is_expected.to have_db_column(:started_on).of_type(:date) }
  it { is_expected.to have_db_column(:ended_on).of_type(:date) }
  it { is_expected.to have_db_column(:presentation_type).of_type(:string) }
  it { is_expected.to have_db_column(:classification).of_type(:string) }
  it { is_expected.to have_db_column(:meet_type).of_type(:string) }
  it { is_expected.to have_db_column(:attendance).of_type(:integer) }
  it { is_expected.to have_db_column(:refereed).of_type(:string) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }
  it { is_expected.to have_db_column(:comment).of_type(:text) }
  it { is_expected.to have_db_column(:scope).of_type(:string) }
  it { is_expected.to have_db_column(:updated_by_user_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:visible).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:activity_insight_identifier).unique(true) }
end

describe Presentation, type: :model do
  it_behaves_like "an application record"

  it { is_expected.to validate_presence_of(:activity_insight_identifier) }

  it { is_expected.to have_many(:presentation_contributions) }
  it { is_expected.to have_many(:users).through(:presentation_contributions) }

  context "given an otherwise valid presentation" do
    subject { build :presentation }

    it { is_expected.to validate_uniqueness_of(:activity_insight_identifier) }
  end

  describe '.visible' do
    let(:visible_pres1) { create :presentation, visible: true }
    let(:visible_pres2) { create :presentation, visible: true }
    let(:invisible_pres) { create :presentation, visible: false }
    it "returns the presentations that are marked as visible" do
      expect(Presentation.visible).to match_array [visible_pres1, visible_pres2]
    end
  end

  describe '#mark_as_updated_by_user' do
    let(:pres) { Presentation.new }
    before { allow(Time).to receive(:current).and_return Time.new(2018, 8, 23, 10, 7, 0) }

    it "sets the presentation's updated_by_user_at field to the current time" do
      pres.mark_as_updated_by_user
      expect(pres.updated_by_user_at).to eq Time.new(2018, 8, 23, 10, 7, 0)
    end
  end

  describe '#label_name' do
    let(:p) { create :presentation, name: name, title: title }

    context "when the presentation has no title or name" do
      let(:title) { nil }
      let(:name) { nil }

      it "returns the presentation's ID" do
        expect(p.label_name).to eq p.id.to_s
      end
    end

    context "when the presentation has a name" do
      let(:name) { 'Test Name' }

      context "when the presentation has a title" do
        let(:title) { 'Test Title' }

        it "returns the presentation's name followed by its title" do
          expect(p.label_name).to eq 'Test Name - Test Title'
        end
      end

      context "when the presentation has no title" do
        let(:title) { nil }

        it "returns the presentation's name" do
          expect(p.label_name).to eq 'Test Name'
        end
      end
    end

    context "when the presentation has a title" do
      let(:title) { 'Test Title' }

      context "when the presentation has no name" do
        let(:name) { nil }

        it "returns the presentation's title" do
          expect(p.label_name).to eq 'Test Title'
        end
      end
    end
  end

  describe '#label' do
    let(:p) { create :presentation, name: name, title: title }

    context "when the presentation has no title or name" do
      let(:title) { nil }
      let(:name) { nil }

      it "returns nil" do
        expect(p.label).to be_nil
      end
    end

    context "when the presentation has a name" do
      let(:name) { 'Test Name' }

      context "when the presentation has a title" do
        let(:title) { 'Test Title' }

        it "returns the presentation's name followed by its title" do
          expect(p.label).to eq 'Test Name - Test Title'
        end
      end

      context "when the presentation has no title" do
        let(:title) { nil }

        it "returns the presentation's name" do
          expect(p.label).to eq 'Test Name'
        end
      end
    end

    context "when the presentation has a title" do
      let(:title) { 'Test Title' }

      context "when the presentation has no name" do
        let(:name) { nil }

        it "returns the presentation's title" do
          expect(p.label).to eq 'Test Title'
        end
      end
    end
  end
end
