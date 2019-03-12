require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the education_history_items table', type: :model do
  subject { EducationHistoryItem.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:activity_insight_identifier).of_type(:string) }
  it { is_expected.to have_db_column(:degree).of_type(:string) }
  it { is_expected.to have_db_column(:explanation_of_other_degree).of_type(:text) }
  it { is_expected.to have_db_column(:is_honorary_degree).of_type(:string) }
  it { is_expected.to have_db_column(:is_highest_degree_earned).of_type(:string) }
  it { is_expected.to have_db_column(:institution).of_type(:text) }
  it { is_expected.to have_db_column(:school).of_type(:text) }
  it { is_expected.to have_db_column(:location_of_institution).of_type(:text) }
  it { is_expected.to have_db_column(:emphasis_or_major).of_type(:text) }
  it { is_expected.to have_db_column(:supporting_areas_of_emphasis).of_type(:text) }
  it { is_expected.to have_db_column(:dissertation_or_thesis_title).of_type(:text) }
  it { is_expected.to have_db_column(:honor_or_distinction).of_type(:text) }
  it { is_expected.to have_db_column(:description).of_type(:text) }
  it { is_expected.to have_db_column(:comments).of_type(:text) }
  it { is_expected.to have_db_column(:start_year).of_type(:integer) }
  it { is_expected.to have_db_column(:end_year).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index(:user_id) }

  it { is_expected.to have_db_foreign_key(:user_id) }
end

describe EducationHistoryItem, type: :model do
  subject(:item) { EducationHistoryItem.new }

  it_behaves_like "an application record"

  it { is_expected.to validate_presence_of(:user) }

  it { is_expected.to belong_to(:user) }
end
