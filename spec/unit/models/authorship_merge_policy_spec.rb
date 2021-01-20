require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/models/authorship_merge_policy'

describe AuthorshipMergePolicy do
  let(:amp) { AuthorshipMergePolicy.new(authorships) }

  describe '#orcid_resource_id_to_keep' do
    let(:authorships) { [auth1, auth2, auth3] }
    let(:auth1) { double 'authorship 1', orcid_resource_identifier: nil, updated_by_owner: Time.new(2000, 1, 1, 0, 0, 0) }
    let(:auth2) { double 'authorship 2', orcid_resource_identifier: nil, updated_by_owner: Time.new(2000, 1, 1, 0, 0, 0) }
    let(:auth3) { double 'authorship 3', orcid_resource_identifier: nil, updated_by_owner: Time.new(2000, 1, 1, 0, 0, 0) }

    context "when given authorships that don't have any orcid resource identifiers" do
      it "returns nil" do
        expect(amp.orcid_resource_id_to_keep).to eq nil
      end
    end

    context "when given authorships where one has an orcid resource identifier" do
      before { allow(auth2).to receive(:orcid_resource_identifier).and_return 'id' }
      it "returns the identifier" do
        expect(amp.orcid_resource_id_to_keep).to eq 'id'
      end
    end

    context "when given authorships where two have orcid resource identifiers" do
      before do
        allow(auth1).to receive(:orcid_resource_identifier).and_return 'id1'
        allow(auth2).to receive(:orcid_resource_identifier).and_return 'id2'
      end

      context "when all of the authorships have been updated by their owners at the same time" do
        it "returns the identifier from the last authorship" do
          expect(amp.orcid_resource_id_to_keep).to eq 'id2'
        end
      end

      context "when the authorships have not all been updated by their owners at the same time" do
        before do
          allow(auth1).to receive(:updated_by_owner).and_return Time.new(2010, 1, 1, 0, 0, 0)
          allow(auth1).to receive(:updated_by_owner).and_return Time.new(2000, 1, 1, 0, 0, 0)
          allow(auth1).to receive(:updated_by_owner).and_return Time.new(2020, 1, 1, 0, 0, 0)
        end

        it "returns the identifier from the most recently updated authorship that has one" do
          expect(amp.orcid_resource_id_to_keep).to eq 'id1'
        end
      end
    end
  end

  describe '#confirmed_value_to_keep' do
    let(:authorships) { [auth1, auth2] }
    let(:auth1) { double 'authorship 1', confirmed: false }
    let(:auth2) { double 'authorship 2', confirmed: false }

    context "when given two unconfirmed authorships" do
      it "returns false" do
        expect(amp.confirmed_value_to_keep).to eq false
      end
    end

    context "when given two authorships where one is confirmed" do
      before { allow(auth1).to receive(:confirmed).and_return true }

      it "returns true" do
        expect(amp.confirmed_value_to_keep).to eq true
      end
    end
  end

  describe '#role_to_keep' do
    let(:authorships) { [auth1, auth2] }
    let(:auth1) { double 'authorship 1', role: nil }
    let(:auth2) { double 'authorship 2', role: nil }

    context "when given two authorships without roles" do
      it "returns nil" do
        expect(amp.role_to_keep).to eq nil
      end
    end

    context "when given two authorships where one has a role" do
      before { allow(auth2).to receive(:role).and_return 'a role' }

      it "returns the role" do
        expect(amp.role_to_keep).to eq 'a role'
      end
    end

    context "when given two authorships where both have roles" do
      before { allow(auth1).to receive(:role).and_return 'role 1' }
      before { allow(auth2).to receive(:role).and_return 'role 2' }

      it "returns the role of the first authorship" do
        expect(amp.role_to_keep).to eq 'role 1'
      end
    end
  end

  describe '#oa_timestamp_to_keep' do
    let(:authorships) { [auth1, auth2] }
    let(:auth1) { double 'authorship 1', open_access_notification_sent_at: nil }
    let(:auth2) { double 'authorship 2', open_access_notification_sent_at: nil }
    
    context "when given two authorships without open access notification timestamps" do
      it "returns nil" do
        expect(amp.oa_timestamp_to_keep).to be_nil
      end
    end

    context "when given two authorships where only one has an open access notification timestamp" do
      before { allow(auth2).to receive(:open_access_notification_sent_at).and_return Time.new(2000, 1, 1, 0, 0, 0) }

      it "returns the timestamp" do
        expect(amp.oa_timestamp_to_keep).to eq Time.new(2000, 1, 1, 0, 0, 0)
      end
    end

    context "when given two authorships that each have an open access notification timestamp" do
      before { allow(auth1).to receive(:open_access_notification_sent_at).and_return Time.new(2010, 1, 1, 0, 0, 0) }
      before { allow(auth2).to receive(:open_access_notification_sent_at).and_return Time.new(2000, 1, 1, 0, 0, 0) }

      it "returns the more recent timestamp" do
        expect(amp.oa_timestamp_to_keep).to eq Time.new(2010, 1, 1, 0, 0, 0)
      end
    end
  end

  describe '#owner_update_timestamp_to_keep' do
    let(:authorships) { [auth1, auth2] }
    let(:auth1) { double 'authorship 1', updated_by_owner_at: nil }
    let(:auth2) { double 'authorship 2', updated_by_owner_at: nil }
    
    context "when given two authorships without owner modification timestamps" do
      it "returns nil" do
        expect(amp.owner_update_timestamp_to_keep).to be_nil
      end
    end

    context "when given two authorships where only one has an owner modification timestamp" do
      before { allow(auth2).to receive(:updated_by_owner_at).and_return Time.new(2000, 1, 1, 0, 0, 0) }

      it "returns the timestamp" do
        expect(amp.owner_update_timestamp_to_keep).to eq Time.new(2000, 1, 1, 0, 0, 0)
      end
    end

    context "when given two authorships that each have an owner modification timestamp" do
      before { allow(auth1).to receive(:updated_by_owner_at).and_return Time.new(2010, 1, 1, 0, 0, 0) }
      before { allow(auth2).to receive(:updated_by_owner_at).and_return Time.new(2000, 1, 1, 0, 0, 0) }

      it "returns the more recent timestamp" do
        expect(amp.owner_update_timestamp_to_keep).to eq Time.new(2010, 1, 1, 0, 0, 0)
      end
    end
  end
end
