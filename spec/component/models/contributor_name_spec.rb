# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_application_record'

describe 'the contributor_names_table', type: :model do
  subject { ContributorName.new }

  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:publication_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:position).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  it { is_expected.to have_db_column(:role).of_type(:string) }
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }

  it { is_expected.to have_db_foreign_key(:publication_id) }
  it { is_expected.to have_db_foreign_key(:user_id) }

  it { is_expected.to have_db_index(:publication_id) }
  it { is_expected.to have_db_index(:user_id) }
end

describe ContributorName, type: :model do
  subject(:cn) { described_class.new }

  let(:fn) { nil }
  let(:mn) { nil }
  let(:ln) { nil }
  let(:user) { nil }

  it_behaves_like 'an application record'

  it { is_expected.to validate_presence_of :publication }
  it { is_expected.to validate_presence_of :position }

  it { is_expected.to belong_to(:publication).inverse_of(:contributor_names) }
  it { is_expected.to belong_to(:user).inverse_of(:contributor_names).optional }
  it { is_expected.to delegate_method(:webaccess_id).to(:user).allow_nil }
  it { is_expected.to delegate_method(:is_active).to(:user).allow_nil }

  describe 'Validating that a contributor has at least one name' do
    let(:cn) { described_class.new(publication: create(:publication),
                                   user: user,
                                   position: 1,
                                   first_name: fn,
                                   middle_name: mn,
                                   last_name: ln) }

    context "when only the contributor's first name is present" do
      let(:fn) { 'first' }

      it 'is valid' do
        expect(cn.valid?).to be true
      end
    end

    context "when only the contributor's middle name is present" do
      let(:mn) { 'middle' }

      it 'is valid' do
        expect(cn.valid?).to be true
      end
    end

    context "when only the contributor's last name is present" do
      let(:ln) { 'last' }

      it 'is valid' do
        expect(cn.valid?).to be true
      end
    end

    context "when all of the contributor's names are nil" do
      it 'is invalid' do
        expect(cn.valid?).to be false
        expect(cn.errors[:base]).to include 'At least one name must be present.'
      end
    end

    context "when all of the contributor's names are empty strings" do
      let(:fn) { '' }
      let(:mn) { '' }
      let(:ln) { '' }

      it 'is invalid' do
        expect(cn.valid?).to be false
        expect(cn.errors[:base]).to include 'At least one name must be present.'
      end
    end

    context "when all of the contributor's names are blank strings" do
      let(:fn) { ' ' }
      let(:mn) { ' ' }
      let(:ln) { ' ' }

      it 'is invalid' do
        expect(cn.valid?).to be false
        expect(cn.errors[:base]).to include 'At least one name must be present.'
      end
    end
  end

  describe '#name' do
    context 'when the first, middle, and last names of the contributor are nil' do
      it 'returns an empty string' do
        expect(cn.name).to eq ''
      end
    end

    context 'when the contributor has a first name' do
      before { cn.first_name = 'first' }

      context 'when the contributor has a middle name' do
        before { cn.middle_name = 'middle' }

        context 'when the contributor has a last name' do
          before { cn.last_name = 'last' }

          it 'returns the full name of the contributor' do
            expect(cn.name).to eq 'first middle last'
          end
        end

        context 'when the contributor has no last name' do
          before { cn.last_name = '' }

          it 'returns the full name of the contributor' do
            expect(cn.name).to eq 'first middle'
          end
        end
      end

      context 'when the contributor has no middle name' do
        before { cn.middle_name = '' }

        context 'when the contributor has a last name' do
          before { cn.last_name = 'last' }

          it 'returns the full name of the contributor' do
            expect(cn.name).to eq 'first last'
          end
        end

        context 'when the contributor has no last name' do
          before { cn.last_name = '' }

          it 'returns the full name of the contributor' do
            expect(cn.name).to eq 'first'
          end
        end
      end
    end

    context 'when the contributor has no first name' do
      before { cn.first_name = '' }

      context 'when the contributor has a middle name' do
        before { cn.middle_name = 'middle' }

        context 'when the contributor has a last name' do
          before { cn.last_name = 'last' }

          it 'returns the full name of the contributor' do
            expect(cn.name).to eq 'middle last'
          end
        end

        context 'when the contributor has no last name' do
          before { cn.last_name = '' }

          it 'returns the full name of the contributor' do
            expect(cn.name).to eq 'middle'
          end
        end
      end

      context 'when the contributor has no middle name' do
        before { cn.middle_name = '' }

        context 'when the contributor has a last name' do
          before { cn.last_name = 'last' }

          it 'returns the full name of the contributor' do
            expect(cn.name).to eq 'last'
          end
        end

        context 'when the contributor has no last name' do
          before { cn.last_name = '' }

          it 'returns an empty string' do
            expect(cn.name).to eq ''
          end
        end
      end
    end
  end

  describe '#to_scholarsphere_creator' do
    let(:cn) { create(:contributor_name,
                      user: user,
                      first_name: fn,
                      middle_name: mn,
                      last_name: ln) }

    context "when the contributor name doesn't have an associated user" do
      context 'when the contributor has a first name' do
        let(:fn) { 'first' }

        context 'when the contributor has a middle name' do
          let(:mn) { 'middle' }

          context 'when the contributor has a last name' do
            let(:ln) { 'last' }

            it 'returns a hash with the full name of the contributor' do
              expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first middle last' })
            end
          end

          context 'when the contributor has no last name' do
            let(:ln) { '' }

            it 'returns a hash with the full name of the contributor' do
              expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first middle' })
            end
          end
        end

        context 'when the contributor has no middle name' do
          let(:mn) { '' }

          context 'when the contributor has a last name' do
            let(:ln) { 'last' }

            it 'returns a hash with the full name of the contributor' do
              expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first last' })
            end
          end

          context 'when the contributor has no last name' do
            let(:ln) { '' }

            it 'returns a hash with the full name of the contributor' do
              expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first' })
            end
          end
        end
      end

      context 'when the contributor has no first name' do
        let(:fn) { '' }

        context 'when the contributor has a middle name' do
          let(:mn) { 'middle' }

          context 'when the contributor has a last name' do
            let(:ln) { 'last' }

            it 'returns a hash with the full name of the contributor' do
              expect(cn.to_scholarsphere_creator).to eq ({ display_name: 'middle last' })
            end
          end

          context 'when the contributor has no last name' do
            let(:ln) { '' }

            it 'returns a hash with the full name of the contributor' do
              expect(cn.to_scholarsphere_creator).to eq ({ display_name: 'middle' })
            end
          end
        end

        context 'when the contributor has no middle name' do
          let(:mn) { '' }

          context 'when the contributor has a last name' do
            let(:ln) { 'last' }

            it 'returns a hash with the full name of the contributor' do
              expect(cn.to_scholarsphere_creator).to eq ({ display_name: 'last' })
            end
          end
        end
      end
    end

    context 'when the contributor names has an associated user' do
      let(:user) { User.new(webaccess_id: 'abc123', orcid_identifier: orcid) }

      context 'when the user has an ORCID ID' do
        let(:orcid) { 'https://orcid.org/orcid-id-123' }

        context 'when the contributor has a first name' do
          let(:fn) { 'first' }

          context 'when the contributor has a middle name' do
            let(:mn) { 'middle' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name, WebAccess ID, and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', orcid: 'orcidid123', display_name: 'first middle last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ orcid: 'orcidid123', display_name: 'first middle last' })
                end
              end
            end

            context 'when the contributor has no last name' do
              let(:ln) { '' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name, WebAccess ID, and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', orcid: 'orcidid123', display_name: 'first middle' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ orcid: 'orcidid123', display_name: 'first middle' })
                end
              end
            end
          end

          context 'when the contributor has no middle name' do
            let(:mn) { '' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name, WebAccess ID, and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', orcid: 'orcidid123', display_name: 'first last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ orcid: 'orcidid123', display_name: 'first last' })
                end
              end
            end

            context 'when the contributor has no last name' do
              let(:ln) { '' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name, WebAccess ID, and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', orcid: 'orcidid123', display_name: 'first' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ orcid: 'orcidid123', display_name: 'first' })
                end
              end
            end
          end
        end

        context 'when the contributor has no first name' do
          let(:fn) { '' }

          context 'when the contributor has a middle name' do
            let(:mn) { 'middle' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name, WebAccess ID, and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ psu_id: 'abc123', orcid: 'orcidid123', display_name: 'middle last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ orcid: 'orcidid123', display_name: 'middle last' })
                end
              end
            end

            context 'when the contributor has no last name' do
              let(:ln) { '' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name, WebAccess ID, and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ psu_id: 'abc123', orcid: 'orcidid123', display_name: 'middle' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ orcid: 'orcidid123', display_name: 'middle' })
                end
              end
            end
          end

          context 'when the contributor has no middle name' do
            let(:mn) { '' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name, WebAccess ID, and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ psu_id: 'abc123', orcid: 'orcidid123', display_name: 'last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name and ORCID ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ orcid: 'orcidid123', display_name: 'last' })
                end
              end
            end
          end
        end
      end

      context 'when the user does not have an ORCID ID' do
        let(:orcid) { nil }

        context 'when the contributor has a first name' do
          let(:fn) { 'first' }

          context 'when the contributor has a middle name' do
            let(:mn) { 'middle' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name and WebAccess ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', display_name: 'first middle last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first middle last' })
                end
              end
            end

            context 'when the contributor has no last name' do
              let(:ln) { '' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name and WebAccess ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', display_name: 'first middle' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first middle' })
                end
              end
            end
          end

          context 'when the contributor has no middle name' do
            let(:mn) { '' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name and WebAccess ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', display_name: 'first last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first last' })
                end
              end
            end

            context 'when the contributor has no last name' do
              let(:ln) { '' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name and WebAccess ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ psu_id: 'abc123', display_name: 'first' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq({ display_name: 'first' })
                end
              end
            end
          end
        end

        context 'when the contributor has no first name' do
          let(:fn) { '' }

          context 'when the contributor has a middle name' do
            let(:mn) { 'middle' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name and WebAccess ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ psu_id: 'abc123', display_name: 'middle last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ display_name: 'middle last' })
                end
              end
            end

            context 'when the contributor has no last name' do
              let(:ln) { '' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name and WebAccess ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ psu_id: 'abc123', display_name: 'middle' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ display_name: 'middle' })
                end
              end
            end
          end

          context 'when the contributor has no middle name' do
            let(:mn) { '' }

            context 'when the contributor has a last name' do
              let(:ln) { 'last' }

              context 'when the contributor is active' do
                before do
                  allow(user).to receive(:is_active).and_return true
                end

                it 'returns a hash with the full name and WebAccess ID of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ psu_id: 'abc123', display_name: 'last' })
                end
              end

              context 'when the contributor is not active' do
                before do
                  allow(user).to receive(:is_active).and_return false
                end

                it 'returns a hash with the full name of the contributor' do
                  expect(cn.to_scholarsphere_creator).to eq ({ display_name: 'last' })
                end
              end
            end
          end
        end
      end
    end
  end
end
