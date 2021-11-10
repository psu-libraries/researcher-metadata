# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe DeputyAssignmentComponent, type: :component do
  let(:deputy_assignment) { build_stubbed :deputy_assignment, primary: primary, deputy: deputy, confirmed_at: confirmed_at }
  let(:primary) { build_stubbed :user, first_name: 'Primary', last_name: 'User', webaccess_id: 'pri123' }
  let(:deputy) { build_stubbed :user, first_name: 'Deputy', last_name: 'User', webaccess_id: 'dep456' }
  let(:confirmed_at) { nil }

  before do
    render_inline(described_class.new(deputy_assignment: deputy_assignment, current_user: current_user))
  end

  context 'when current_user is the primary' do
    let(:current_user) { primary }

    it 'shows the name and access id of the deputy' do
      expect(rendered_component).to have_css('.deputy-assignment__name', text: 'Deputy User dep456')
    end

    context 'when the deputy_assignment is pending confirmation' do
      let(:confirmed_at) { nil }

      it 'shows a "pending" message' do
        expect(rendered_component).to have_text(I18n.t!('view_component.deputy_assignment_component.pending_as_primary'))
      end

      it 'shows the delete button' do
        expect(rendered_component).to have_button(I18n.t!('view_component.deputy_assignment_component.delete_as_primary'), class: 'btn-outline-danger')
      end
    end

    context 'when the deputy_assignment has been confirmed' do
      let(:confirmed_at) { Time.zone.now }

      it 'does not show a "pending" message' do
        expect(rendered_component).not_to have_text(I18n.t!('view_component.deputy_assignment_component.pending_as_primary'))
      end

      it 'shows the delete button' do
        expect(rendered_component).to have_button(I18n.t!('view_component.deputy_assignment_component.delete_as_primary'), class: 'btn-outline-danger')
      end
    end
  end

  context 'when current_user is the deputy' do
    let(:current_user) { deputy }

    it 'shows the name and access id of the primary' do
      expect(rendered_component).to have_css('.deputy-assignment__name', text: 'Primary User pri123')
    end

    context 'when the deputy_assignment is pending confirmation' do
      let(:confirmed_at) { nil }

      it 'adds an action-required class' do
        expect(rendered_component).to have_css('.deputy-assignment--action-required')
      end

      it 'shows an action-required message' do
        expect(rendered_component).to have_text(I18n.t!('view_component.deputy_assignment_component.pending_as_deputy'))
      end

      it 'shows a button to accept the DeputyAssignment' do
        expect(rendered_component).to have_button(I18n.t!('view_component.deputy_assignment_component.accept'))
      end

      it 'shows a special delete button' do
        expect(rendered_component).to have_button(I18n.t!('view_component.deputy_assignment_component.delete_as_deputy_unconfirmed'), class: 'btn-outline-secondary')
      end
    end

    context 'when the deputy_assignment has been confirmed' do
      let(:confirmed_at) { Time.zone.now }

      it 'does not add an action-required class' do
        expect(rendered_component).not_to have_css('.deputy-assignment--action-required')
      end

      it 'does not show an action-required message' do
        expect(rendered_component).not_to have_text(I18n.t!('view_component.deputy_assignment_component.pending_as_deputy'))
      end

      it 'does not show a button to accept the DeputyAssignment' do
        expect(rendered_component).not_to have_button(I18n.t!('view_component.deputy_assignment_component.accept'))
      end

      it 'shows the delete button' do
        expect(rendered_component).to have_button(I18n.t!('view_component.deputy_assignment_component.delete_as_deputy'), class: 'btn-outline-danger')
      end
    end
  end
end
