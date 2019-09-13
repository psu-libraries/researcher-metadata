require 'component/component_spec_helper'

describe NSFGrantImporter do
  let(:importer) { NSFGrantImporter.new(dirname: dirname) }

  describe '#call' do
    context "when given XML files of grant data from the National Science Foundation" do
      let(:dirname) { Rails.root.join('spec', 'fixtures', 'nsf_grants') }

      context "when no grants matching the data in the given files already exist" do
        xit "creates new grant records for each Penn State grant in the given data that matches a user" do
        end

        xit "creates associations between the new grants and users based on the given data" do

        end
      end

      context "when a grant matching the data in the given files already exists" do
        xit "creates new grant records for each Penn State grant in the given data that matches a user and does not match an existing grant" do

        end

        xit "creates associations between the new grants and users based on the given data" do

        end

        xit "updates the existing grant with the given data" do

        end

        context "when an association between the existing grant and a user already exists" do
          xit "does not create a new association" do

          end
        end

        context "when no associations between the existing grant and users exist" do
          xit "creates a new association based on the given data" do

          end
        end
      end
    end
  end
end
