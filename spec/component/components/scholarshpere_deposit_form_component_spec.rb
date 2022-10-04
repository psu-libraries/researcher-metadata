# frozen_string_literal: true

require 'component/component_spec_helper'

RSpec.describe ScholarsphereDepositFormComponent, type: :component do
  let(:oab_permissions) do
    Struct.new('OabPermissionsService', :permissions,
                                        :this_version,
                                        :licence,
                                        :embargo_end_date,
                                        :set_statement,
                                        :other_version_preferred)
  end
  let!(:publication) { FactoryBot.create :sample_publication }
  let(:op) do
    op = oab_permissions.new
    op.this_version = { 'version' => 'acceptedVersion' }
    op.permissions = { 'version' => 'acceptedVersion' }
    op.licence = 'https://creativecommons.org/licenses/by/4.0/'
    op.embargo_end_date = Date.tomorrow
    op.set_statement = 'Statement'
    op.other_version_preferred = false
    op
  end

  before do
    deposit = ScholarsphereWorkDeposit.new_from_authorship(publication.authorships.first)
    with_controller_class OpenAccessPublicationsController do
      allow_any_instance_of(ActionDispatch::Request).to receive(:path_parameters).and_return({ id: publication.id })
      render_inline(ScholarsphereDepositFormComponent.new(deposit, op))
    end
  end

  context 'when doi is present in the publication' do
    it 'renders doi field readonly' do
      expect(page).to have_field('DOI', readonly: true)
    end
  end
end
