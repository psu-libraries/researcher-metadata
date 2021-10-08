# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the email_errors table', type: :model do
  subject { EmailError.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:message).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  it { is_expected.to have_db_index :user_id }

  it { is_expected.to have_db_foreign_key(:user_id) }
end

describe EmailError, type: :model do
  it_behaves_like 'an application record'

  it { is_expected.to belong_to(:user) }
end
