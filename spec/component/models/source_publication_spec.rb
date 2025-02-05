# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the source_publications table', type: :model do
  subject { SourcePublication.new }

  it { is_expected.to have_db_column(:source_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:status).of_type(:string) }
  it { is_expected.to have_db_column(:import_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:import_id) }
  it { is_expected.to have_db_foreign_key(:import_id) }
end

describe SourcePublication, type: :model do
  it_behaves_like 'an application record'

  describe 'associations' do
    it { is_expected.to belong_to(:import) }
  end
end
