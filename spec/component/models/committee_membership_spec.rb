# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the committee_memberships table', type: :model do
  subject { CommitteeMembership.new }

  it { is_expected.to have_db_column(:etd_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:role).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :etd_id }
  it { is_expected.to have_db_index :user_id }

  it { is_expected.to have_db_foreign_key(:etd_id) }
  it { is_expected.to have_db_foreign_key(:user_id) }
end

describe CommitteeMembership, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:etd).inverse_of(:committee_memberships) }
    it { is_expected.to belong_to(:user).inverse_of(:committee_memberships) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:etd_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:role) }

    context 'given otherwise valid data' do
      subject { described_class.new(etd: create(:etd), user: create(:user), role: 'Advisor') }

      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:etd_id, :role) }
    end
  end

  describe '#<=>' do
    let(:mem) { described_class.new(role: role) }

    context "when the committee membership has a role of 'Dissertation Advisor'" do
      let(:role) { 'Dissertation Advisor' }

      context 'when given another committee membership with a role of Dissertation Advisor' do
        it 'returns 0' do
          expect(mem <=> described_class.new(role: 'Dissertation Advisor')).to eq 0
        end
      end

      context 'when given another committee membership with a role of Thesis Advisor' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Thesis Advisor')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Committee Chair' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Committee Chair')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Committee Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Committee Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Outside Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Outside Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Special Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Special Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role not in the rank list' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Unknown Member')).to eq 1
        end
      end
    end

    context "when the committee membership has a role of 'Thesis Advisor'" do
      let(:role) { 'Thesis Advisor' }

      context 'when given another committee membership with a role of Dissertation Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Dissertation Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Thesis Advisor' do
        it 'returns 0' do
          expect(mem <=> described_class.new(role: 'Thesis Advisor')).to eq 0
        end
      end

      context 'when given another committee membership with a role of Committee Chair' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Committee Chair')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Committee Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Committee Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Outside Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Outside Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Special Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Special Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role not in the rank list' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Unknown Member')).to eq 1
        end
      end
    end

    context "when the committee membership has a role of 'Committee Chair'" do
      let(:role) { 'Committee Chair' }

      context 'when given another committee membership with a role of Dissertation Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Dissertation Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Thesis Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Thesis Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Chair' do
        it 'returns 0' do
          expect(mem <=> described_class.new(role: 'Committee Chair')).to eq 0
        end
      end

      context 'when given another committee membership with a role of Committee Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Committee Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Outside Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Outside Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Special Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Special Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role not in the rank list' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Unknown Member')).to eq 1
        end
      end
    end

    context "when the committee membership has a role of 'Committee Member'" do
      let(:role) { 'Committee Member' }

      context 'when given another committee membership with a role of Dissertation Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Dissertation Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Thesis Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Thesis Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Chair' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Committee Chair')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Member' do
        it 'returns 0' do
          expect(mem <=> described_class.new(role: 'Committee Member')).to eq 0
        end
      end

      context 'when given another committee membership with a role of Outside Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Outside Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role of Special Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Special Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role not in the rank list' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Unknown Member')).to eq 1
        end
      end
    end

    context "when the committee membership has a role of 'Outside Member'" do
      let(:role) { 'Outside Member' }

      context 'when given another committee membership with a role of Dissertation Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Dissertation Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Thesis Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Thesis Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Chair' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Committee Chair')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Member' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Committee Member')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Outside Member' do
        it 'returns 0' do
          expect(mem <=> described_class.new(role: 'Outside Member')).to eq 0
        end
      end

      context 'when given another committee membership with a role of Special Member' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Special Member')).to eq 1
        end
      end

      context 'when given another committee membership with a role not in the rank list' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Unknown Member')).to eq 1
        end
      end
    end

    context "when the committee membership has a role of 'Special Member'" do
      let(:role) { 'Special Member' }

      context 'when given another committee membership with a role of Dissertation Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Dissertation Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Thesis Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Thesis Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Chair' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Committee Chair')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Member' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Committee Member')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Outside Member' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Outside Member')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Special Member' do
        it 'returns 0' do
          expect(mem <=> described_class.new(role: 'Special Member')).to eq 0
        end
      end

      context 'when given another committee membership with a role not in the rank list' do
        it 'returns 1' do
          expect(mem <=> described_class.new(role: 'Unknown Member')).to eq 1
        end
      end
    end

    context 'when the committee membership role is not in the rank list' do
      let(:role) { 'Unknown Member' }

      context 'when given another committee membership with a role of Dissertation Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Dissertation Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Thesis Advisor' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Thesis Advisor')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Chair' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Committee Chair')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Committee Member' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Committee Member')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Outside Member' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Outside Member')).to eq -1
        end
      end

      context 'when given another committee membership with a role of Special Member' do
        it 'returns -1' do
          expect(mem <=> described_class.new(role: 'Special Member')).to eq -1
        end
      end

      context 'when given another committee membership with a role not in the rank list' do
        it 'returns 0' do
          expect(mem <=> described_class.new(role: 'Unknown Member')).to eq 0
        end
      end
    end
  end

  describe '#unknown_role_check' do
    let!(:cm) { FactoryBot.create :committee_membership }

    context 'when updating role with a role in the RANK_LIST' do
      it 'does not trigger bugsnag' do
        allow(Bugsnag).to receive(:notify).with(I18n.t('models.committee_memberships.unknown_role_message', role: 'Dissertation Advisor'))
        cm.update role: 'Dissertation Advisor'
        expect(Bugsnag).not_to have_received(:notify).with(I18n.t('models.committee_memberships.unknown_role_message', role: 'Unknown Member'))
      end
    end

    context 'when updating role with a role not in the RANK_LIST' do
      it 'triggers bugsnag' do
        allow(Bugsnag).to receive(:notify).with(I18n.t('models.committee_memberships.unknown_role_message', role: 'Unknown Member')).once
        cm.update role: 'Unknown Member'
        expect(Bugsnag).to have_received(:notify).with(I18n.t('models.committee_memberships.unknown_role_message', role: 'Unknown Member')).once
      end
    end
  end
end
