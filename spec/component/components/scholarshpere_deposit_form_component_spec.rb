# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe ScholarsphereDepositFormComponent, type: :component do
  let(:oab_permissions) do
    Struct.new('OabPermissionsService', :permissions,
               :version,
               :this_version,
               :licence,
               :embargo_end_date,
               :set_statement,
               :other_version_preferred?)
  end
  let!(:publication) { create :sample_publication }
  let(:op) do
    op = oab_permissions.new
    op.version = 'acceptedVersion'
    op.this_version = { 'version' => 'acceptedVersion' }
    op.permissions = { 'version' => 'acceptedVersion' }
    op.licence = 'https://creativecommons.org/licenses/by/4.0/'
    op.embargo_end_date = Date.tomorrow
    op.set_statement = 'Statement'
    op[:other_version_preferred?] = false
    op
  end

  def view_render
    # Trying to mimic what the OpenAccessPublicationsController#scholarsphere_deposit_form does
    deposit = ScholarsphereWorkDeposit.new_from_authorship(publication.authorships.first, { rights: op.licence,
                                                                                            embargoed_until: op.embargo_end_date,
                                                                                            publisher_statement: op.set_statement })
    with_controller_class OpenAccessPublicationsController do
      allow_any_instance_of(ActionDispatch::Request).to receive(:path_parameters).and_return({ id: publication.id })
      render_inline(ScholarsphereDepositFormComponent.new(deposit, op))
    end
  end

  context 'when doi is present in the publication' do
    it 'renders doi field readonly' do
      view_render
      expect(page).to have_field('DOI', readonly: true)
    end
  end

  context 'when doi is not present in the publication' do
    before do
      publication.update doi: nil
      publication.reload
    end

    it 'renders editable doi field' do
      view_render
      expect(page).not_to have_field('DOI', readonly: true)
      expect(page).to have_field('DOI')
    end
  end

  context 'when our version is found from oab permissions api' do
    it 'renders an alert saying sharing rules have been found' do
      view_render
      expect(page).to have_text('We found sharing rules for your work')
    end

    context 'when a license is found' do
      it 'renders a notice saying a license has been found' do
        view_render
        expect(page).to have_text('We found the license for your work')
        expect(page).to have_field('License', with: 'https://creativecommons.org/licenses/by/4.0/')
      end
    end

    context 'when no license is found' do
      before do
        op.licence = nil
      end

      it 'renders no notice and defaults to "All Rights Reserved"' do
        view_render
        expect(page).not_to have_text('We found the license for your work')
        expect(page).to have_field('License', with: 'https://rightsstatements.org/page/InC/1.0/')
      end
    end

    context 'when a set statement is found' do
      it 'renders a notice saying a set statement has been found and prefills data' do
        view_render
        expect(page).to have_text('We found the set statement for your work')
        expect(page).to have_field('Publisher Statement', with: 'Statement')
      end
    end

    context 'when a set statement is not found' do
      before do
        op.set_statement = nil
      end

      it 'does not render any notice and does not prefill data' do
        view_render
        expect(page).not_to have_text('We found the set statement for your work')
        expect(page).to have_field('Publisher Statement', with: '')
      end
    end

    context 'when an embargo date is found' do
      before do
        op.embargo_end_date = Date.yesterday
      end

      context 'when the embargo date is before today' do
        it 'renders a notice saying an embargo date was found but it is before today so it is blank' do
          view_render
          expect(page).to have_text('We found the embargo end date for your work but it is before the current date, so we left this blank.')
          expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_1i', text: '')
          expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_2i', text: '')
          expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_3i', text: '')
        end
      end

      context 'when the embargo date is after today' do
        it 'renders a notice saying an embargo date has been found and prefills data' do
          view_render
          expect(page).to have_text('We found the embargo end date for your work')
          expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_1i', text: Date.tomorrow.year)
          expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_2i', text: Date.tomorrow.strftime('%B'))
          expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_3i', text: Date.tomorrow.day)
        end
      end
    end

    context 'when an embargo end date is not found' do
      before do
        op.embargo_end_date = nil
      end

      it 'does not render any notice and does not prefill data' do
        view_render
        expect(page).not_to have_text('We found the embargo end date for your work')
        expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_1i', text: '')
        expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_2i', text: '')
        expect(page).to have_css('#scholarsphere_work_deposit_embargoed_until_3i', text: '')
      end
    end
  end

  context 'when our accepted version is not found' do
    before do
      op.this_version = {}
      op[:other_version_preferred?] = true
    end

    context 'when a published version exists' do
      it 'renders an alert saying the published version is preferred' do
        view_render
        expect(page).to have_text('We could not find sharing rules for the acccepted manuscript of this work, only the final published version')
      end
    end

    context 'when a published version does not exist' do
      before do
        op[:other_version_preferred?] = false
      end

      it 'renders an alert saying no sharing rules were found' do
        view_render
        expect(page).to have_text('We could not find sharing rules for your work.')
      end
    end
  end

  context 'when our published version is not found' do
    before do
      op.version = 'publishedVersion'
      op.this_version = {}
      op[:other_version_preferred?] = true
    end

    context 'when an accepted version exists' do
      it 'renders an alert saying the published version is preferred' do
        view_render
        expect(page).to have_text('We could not find sharing rules for the final published version of this work, only the acccepted manuscript')
      end
    end

    context 'when an accepted version does not exist' do
      before do
        op[:other_version_preferred?] = false
      end

      it 'renders an alert saying no sharing rules were found' do
        view_render
        expect(page).to have_text('We could not find sharing rules for your work.')
      end
    end
  end
end