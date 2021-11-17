# frozen_string_literal: true

require 'component/component_spec_helper'

describe NewDeputyAssignmentForm, type: :model do
  RSpec::Matchers.define_negated_matcher :not_change, :change

  def i18n_error(key)
    I18n.t!("activemodel.errors.models.new_deputy_assignment_form.attributes.#{key}")
  end

  subject(:form) { described_class.new(primary: primary, deputy_webaccess_id: deputy_webaccess_id) }

  let!(:primary) { create :user, first_name: 'Primary' }
  let(:deputy_webaccess_id) { 'dep0987' }

  let(:psu_identity_client) { instance_spy('PsuIdentity::SearchService::Client') }

  before do
    allow(PsuIdentity::SearchService::Client).to receive(:new).and_return(psu_identity_client)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:primary) }
    it { is_expected.to validate_presence_of(:deputy_webaccess_id) }

    it 'validates the basic format of deputy_webaccess_id' do
      expect(form).to allow_value('abc123').for(:deputy_webaccess_id)
      expect(form).to allow_value('ABC123').for(:deputy_webaccess_id)

      expect(form).not_to allow_value('abc123@psu.edu').for(:deputy_webaccess_id)
      expect(form).not_to allow_value('abc 123').for(:deputy_webaccess_id)
    end
  end

  describe '#save' do
    context 'when no User exists for the given webaccess id' do
      let(:psu_identity_data) {
        { 'userid' => 'dep0987', 'cprid' => '123456', 'givenName' => 'Deputy', 'familyName' =>
'FromPsu', 'active' => true, 'confHold' => false, 'serviceAccount' => false, "affiliati
on" => ['MEMBER'], 'displayName' => 'Deputy FromPsu', 'link' => { 'href' => "https://dev.app
s.psu.edu/cpr/resources/123456" } }
      }
      let(:psu_person) { PsuIdentity::SearchService::Person.new(psu_identity_data) }

      context 'when PsuIdentity responds with a valid response' do
        before { allow(psu_identity_client).to receive(:userid).with(deputy_webaccess_id).and_return(psu_person) }

        it 'returns true' do
          expect(form.save).to eq true
        end

        it 'creates a User' do
          expect {
            form.save
          }.to change(User, :count).by(1)

          deputy = User.find_by(webaccess_id: deputy_webaccess_id)
          expect(deputy).to be_present
          expect(deputy.first_name).to eq 'Deputy'
          expect(deputy.last_name).to eq 'FromPsu'
          expect(deputy.psu_identity).to be_present
          expect(deputy.psu_identity_updated_at).to be_within(2.seconds).of(Time.zone.now)
        end

        it 'creates an active DeputyAssignment' do
          expect {
            form.save
          }.to change(DeputyAssignment.active, :count).by(1)

          assignment = DeputyAssignment.active.last
          expect(assignment.primary).to eq primary
          expect(assignment.deputy.webaccess_id).to eq deputy_webaccess_id
        end

        it 'sets :deputy_assignment to the newly created DeputyAssignment' do
          expect {
            form.save
          }.to change(form, :deputy_assignment)
            .from(nil).to(an_instance_of(DeputyAssignment))

          expect(form.deputy_assignment).to eq DeputyAssignment.active.last
        end
      end

      context 'when the webaccess_id is not found in PsuIdentity' do
        before { allow(psu_identity_client).to receive(:userid).with(deputy_webaccess_id).and_return(nil) }

        it 'returns false' do
          expect(form.save).to eq false
        end

        it 'has a nice error' do
          form.save
          expect(form.errors.messages_for(:deputy_webaccess_id)).to include i18n_error('deputy_webaccess_id.not_found')
        end

        it 'creates nothing' do
          expect {
            form.save
          }.to not_change(User, :count)
            .and not_change(DeputyAssignment, :count)
        end

        it 'does not set :deputy_assignment' do
          expect {
            form.save
          }.not_to change(form, :deputy_assignment)
            .from(nil)
        end
      end

      context 'when PsuIdentity raises an error' do
        before { allow(psu_identity_client).to receive(:userid).and_raise(StandardError) }

        it 'returns false' do
          expect(form.save).to eq false
        end

        it 'has a nice error' do
          form.save
          expect(form.errors.messages_for(:base)).to include i18n_error('base.identity_service_error')
        end

        it 'creates nothing' do
          expect {
            form.save
          }.to not_change(User, :count)
            .and not_change(DeputyAssignment, :count)
        end
      end

      context 'when PsuIdentity responds with something, but the data is invalid' do
        before { allow(psu_identity_client).to receive(:userid).with(deputy_webaccess_id).and_return(psu_person) }

        let(:psu_identity_data) { {} }

        it 'returns false' do
          expect(form.save).to eq false
        end

        it 'has a nice error' do
          form.save
          expect(form.errors.messages_for(:base)).to include i18n_error('base.error_creating_user')
        end

        it 'creates nothing' do
          expect {
            form.save
          }.to not_change(User, :count)
            .and not_change(DeputyAssignment, :count)
        end
      end

      context 'when the PsuIdentity responds correctly, but there is a problem creating the DeputyAssignment' do
        before do
          allow(psu_identity_client).to receive(:userid).with(deputy_webaccess_id).and_return(psu_person)
          allow(DeputyAssignment).to receive(:create!).and_raise(StandardError)
        end

        it 'returns false' do
          expect(form.save).to eq false
        end

        it 'has a nice error' do
          form.save
          expect(form.errors.messages_for(:base)).to include i18n_error('base.unknown_error')
        end

        it 'creates nothing' do
          expect {
            form.save
          }.to not_change(User, :count)
            .and not_change(DeputyAssignment, :count)
        end
      end
    end

    context 'when a User exists for the given webaccess id' do
      let!(:existing_user) { create :user, webaccess_id: deputy_webaccess_id, first_name: 'Deputy', last_name: 'FromDB' }

      context 'when everything goes as expected' do
        it 'returns true' do
          expect(form.save).to eq true
        end

        it 'does not query PsuIdentity' do
          form.save
          expect(PsuIdentity::SearchService::Client).not_to have_received(:new)
        end

        it 'does not create any Users' do
          expect {
            form.save
          }.not_to change(User, :count)
        end

        it 'creates an active DeputyAssignment' do
          expect {
            form.save
          }.to change(DeputyAssignment.active, :count).by(1)

          assignment = DeputyAssignment.active.last
          expect(assignment.primary).to eq primary
          expect(assignment.deputy).to eq existing_user
        end
      end

      context 'when an active DeputyAssignment already exists for that User' do
        let!(:existing_deputy_assignment) { create :deputy_assignment, :active, primary: primary, deputy: existing_user }

        it 'returns false' do
          expect(form.save).to eq false
        end

        it 'has a nice error' do
          form.save
          expect(form.errors.messages_for(:deputy_webaccess_id)).to include i18n_error('deputy_webaccess_id.already_assigned')
        end

        it 'creates nothing' do
          expect {
            form.save
          }.to not_change(User, :count)
            .and not_change(DeputyAssignment, :count)
        end
      end

      context 'when an inactive DeputyAssignment already exists for that User' do
        let!(:existing_deputy_assignment) { create :deputy_assignment, :inactive, primary: primary, deputy: existing_user }

        it 'returns true' do
          expect(form.save).to eq true
        end

        it 'creates an active DeputyAssignment' do
          expect {
            form.save
          }.to change(DeputyAssignment.active, :count).by(1)

          assignment = DeputyAssignment.active.last
          expect(assignment.primary).to eq primary
          expect(assignment.deputy).to eq existing_user
        end
      end

      context 'when the DeputyAssignment cannot be created due to being invalid' do
        before do
          primary.update!(is_admin: true)
          existing_user.update!(is_admin: true)
        end

        it 'returns false' do
          expect(form.save).to eq false
        end

        it 'percolates error messages from the DeputyAssignment to the proper place on the form object' do
          form.save
          expect(form.errors.messages_for(:deputy_webaccess_id)).to include(/admin/i)
          expect(form.errors.messages_for(:base)).to include(/admin/i)
        end
      end
    end

    context 'when you try to be your own deputy' do
      let(:deputy_webaccess_id) { primary.webaccess_id }

      it 'returns false' do
        expect(form.save).to eq false
      end

      it 'percolates error messages from the DeputyAssignment to the proper place on the form object' do
        form.save
        expect(form.errors.messages_for(:deputy_webaccess_id)).to include(/same/i)
      end
    end
  end
end
