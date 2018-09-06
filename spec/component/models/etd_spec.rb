require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the etds table', type: :model do
  subject { ETD.new }

  it { is_expected.to have_db_column(:title).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:author_first_name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:author_middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:author_last_name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:webaccess_id).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:year).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:url).of_type(:text).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_type).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:external_identifier).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:access_level).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:webaccess_id) }
  it { is_expected.to have_db_index(:external_identifier) }
end

describe ETD, type: :model do
  it_behaves_like "an application record"

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author_first_name) }
    it { is_expected.to validate_presence_of(:author_last_name) }
    it { is_expected.to validate_presence_of(:webaccess_id) }
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_presence_of(:submission_type) }
    it { is_expected.to validate_presence_of(:external_identifier) }
    it { is_expected.to validate_presence_of(:access_level) }

  end
end
