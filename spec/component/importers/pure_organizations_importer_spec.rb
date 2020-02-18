require 'component/component_spec_helper'

describe PureOrganizationsImporter do
  let(:importer) { PureOrganizationsImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .json file of valid organization data from Pure" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'pure_organizations.json') }

      context "when no organizations exist in the database" do
        it "creates a new organization for every object in the .json file" do
          expect { importer.call }.to change { Organization.count }.by 3

          o1 = Organization.find_by(pure_uuid: 'pure-uuid-001')
          o2 = Organization.find_by(pure_uuid: 'pure-uuid-002')
          o3 = Organization.find_by(pure_uuid: 'pure-uuid-003')

          expect(o1.name).to eq 'Biology'
          expect(o1.pure_external_identifier).to eq 'EXT-ID-1'
          expect(o1.organization_type).to eq 'Department'
          expect(o1.parent).to eq o2

          expect(o2.name).to eq 'College of Science'
          expect(o2.pure_external_identifier).to eq 'EXT-ID-2'
          expect(o2.organization_type).to eq 'College'
          expect(o2.parent).to be_nil

          expect(o3.name).to eq 'College of Nursing'
          expect(o3.pure_external_identifier).to eq 'EXT-ID-3'
          expect(o3.organization_type).to eq 'College'
          expect(o3.parent).to be_nil
        end
      end

      context "when an organization already exists for one of the objects in the .json file" do
        before do
          create :organization,
                 name: 'existing name',
                 pure_uuid: 'pure-uuid-002',
                 pure_external_identifier: 'existing id',
                 organization_type: 'existing type',
                 parent: create(:organization, pure_uuid: 'something')
        end

        it "creates a new organization for every new object in the .json file and updates the existing organization" do
          expect { importer.call }.to change { Organization.count }.by 2

          o1 = Organization.find_by(pure_uuid: 'pure-uuid-001')
          o2 = Organization.find_by(pure_uuid: 'pure-uuid-002')
          o3 = Organization.find_by(pure_uuid: 'pure-uuid-003')

          expect(o1.name).to eq 'Biology'
          expect(o1.pure_external_identifier).to eq 'EXT-ID-1'
          expect(o1.organization_type).to eq 'Department'
          expect(o1.parent).to eq o2

          expect(o2.name).to eq 'College of Science'
          expect(o2.pure_external_identifier).to eq 'EXT-ID-2'
          expect(o2.organization_type).to eq 'College'
          expect(o2.parent).to be_nil

          expect(o3.name).to eq 'College of Nursing'
          expect(o3.pure_external_identifier).to eq 'EXT-ID-3'
          expect(o3.organization_type).to eq 'College'
          expect(o3.parent).to be_nil
        end
      end
    end
  end
end
