require 'component/component_spec_helper'

describe PSUHRUserImporter do
  let(:importer) { PSUHRUserImporter.new(filename: filename) }

  describe '#call' do
    context "when given a CSV file containing user data from Penn State's HR system" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'psu_hr_users.csv') }

      it "doesn't explode at least" do
        importer.call
      end
    end
  end
end
