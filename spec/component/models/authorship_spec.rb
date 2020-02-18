require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the authorships table', type: :model do
  subject { Authorship.new }

  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:author_number).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:visible_in_profile).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:position_in_profile).of_type(:integer) }
  it { is_expected.to have_db_column(:confirmed).of_type(:boolean).with_options(default: true) }
  it { is_expected.to have_db_column(:scholarsphere_uploaded_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:role).of_type(:string) }

  it { is_expected.to have_db_index :user_id }
  it { is_expected.to have_db_index :publication_id }

  it { is_expected.to have_db_foreign_key(:user_id) }
  it { is_expected.to have_db_foreign_key(:publication_id) }
end

describe Authorship, type: :model do
  it_behaves_like "an application record"

  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:authorships) }
    it { is_expected.to belong_to(:publication).inverse_of(:authorships) }
    it { is_expected.to have_one(:waiver).class_name(:InternalPublicationWaiver) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:publication_id) }
    it { is_expected.to validate_presence_of(:author_number) }

    context "given otherwise valid data" do
      subject { Authorship.new(user: create(:user), publication: create(:publication)) }
      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:publication_id) }
    end
  end

  it { is_expected.to delegate_method(:title).to(:publication) }
  it { is_expected.to delegate_method(:abstract).to(:publication) }
  it { is_expected.to delegate_method(:doi).to(:publication) }
  it { is_expected.to delegate_method(:published_by).to(:publication) }
  it { is_expected.to delegate_method(:year).to(:publication) }
  it { is_expected.to delegate_method(:preferred_open_access_url).to(:publication) }
  it { is_expected.to delegate_method(:scholarsphere_upload_pending?).to(:publication) }
  it { is_expected.to delegate_method(:open_access_waived?).to(:publication) }
  it { is_expected.to delegate_method(:user_webaccess_id).to(:user).as(:webaccess_id) }

  describe "#description" do
    let(:a) { create :authorship }
    it "returns a string describing the record" do
      expect(a.description).to eq "Authorship ##{a.id}"
    end
  end

  describe "#no_open_access_information?" do
    let(:pub) { create :publication,
                       open_access_url: url }
    let(:a) { create :authorship,
                     publication: pub,
                     scholarsphere_uploaded_at: upload_ts }

    context "when the authorship's publication has an open access URL" do
      let(:url) { "a-url" }

      context "when the authorship's publication has a pending ScholarSphere upload" do
        let(:upload_ts) { Time.current }

        context "when the authorship's publication has an open access waiver" do
          before { create :internal_publication_waiver, authorship: a}

          it "returns false" do
            expect(a.no_open_access_information?).to eq false
          end
        end

        context "when the authorship's publication does not have an open access waiver" do
          it "returns false" do
            expect(a.no_open_access_information?).to eq false
          end
        end
      end

      context "when the authorship's publication does not have a pending ScholarSphere upload" do
        let(:upload_ts) { nil }

        context "when the authorship's publication has an open access waiver" do
          before { create :internal_publication_waiver, authorship: a}

          it "returns false" do
            expect(a.no_open_access_information?).to eq false
          end
        end

        context "when the authorship's publication does not have an open access waiver" do
          it "returns false" do
            expect(a.no_open_access_information?).to eq false
          end
        end
      end
    end

    context "when the authorship's publication does not have an open access URL" do
      let(:url) { nil }

      context "when the authorship's publication has a pending ScholarSphere upload" do
        let(:upload_ts) { Time.current }

        context "when the authorship's publication has an open access waiver" do
          before { create :internal_publication_waiver, authorship: a}

          it "returns false" do
            expect(a.no_open_access_information?).to eq false
          end
        end

        context "when the authorship's publication does not have an open access waiver" do

          it "returns false" do
            expect(a.no_open_access_information?).to eq false
          end
        end
      end

      context "when the authorship's publication does not have a pending ScholarSphere upload" do
        let(:upload_ts) { nil }

        context "when the authorship's publication has an open access waiver" do
          before { create :internal_publication_waiver, authorship: a}

          it "returns false" do
            expect(a.no_open_access_information?).to eq false
          end
        end

        context "when the authorship's publication does not have an open access waiver" do
          it "returns true" do
            expect(a.no_open_access_information?).to eq true
          end
        end
      end
    end
  end
end
