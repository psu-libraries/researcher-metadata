require 'component/component_spec_helper'

describe PSULawSchoolOAIRepoRecord do
  let(:psu_rr) { PSULawSchoolOAIRepoRecord.new(record) }
  let(:record) { double 'fieldhand record', metadata: metadata_xml_fixture, header: header }
  let(:metadata_xml_fixture) { File.read(Rails.root.join('spec', 'fixtures', 'oai_record_metadata.xml')) }
  let(:header) { double 'fieldhand header', identifier: 'the-identifier' }

  let(:creator1) { double 'creator', user_match: um1, ambiguous_user_matches: aum1 }
  let(:creator2) { double 'creator', user_match: um2, ambiguous_user_matches: aum2 }

  let(:um1) { nil }
  let(:aum1) { [] }
  let(:um2) { nil }
  let(:aum2) { [] }

  before do
    allow(PSULawSchoolOAICreator).to receive(:new).with('Testington, Allie').and_return(creator1)
    allow(PSULawSchoolOAICreator).to receive(:new).with('Testworth, Roger').and_return(creator2)
  end

  describe '#title' do
    it "returns the value of the title attribute from the given metadata object" do
      expect(psu_rr.title).to eq 'Test Law Article'
    end
  end

  describe '#description' do
    it "returns the value of the discription attribute from the given metadata object" do
      expect(psu_rr.description).to eq 'This is a description of the article.'
    end
  end

  describe '#date' do
    it "returns the date parsed from the value of the date attribute from the given metadata object" do
      expect(psu_rr.date).to eq Date.new(2012, 4, 23)
    end
  end

  describe '#url1' do
    it "returns the value of the first identifier attribute from the given metadata object" do
      expect(psu_rr.url1).to eq 'https://elibrary.law.psu.edu/abc/etc/etc'
    end
  end

  describe '#url2' do
    it "returns the value of the second identifier attribute from the given metadata object" do
      expect(psu_rr.url2).to eq 'https://elibrary.law.psu.edu/cgi/viewcontent.cgi'
    end
  end

  describe '#creators' do
    it "returns a creator each creator in the given metadtata" do
      expect(psu_rr.creators).to eq [creator1, creator2]
    end
  end

  describe '#identifier' do
    it "returns the identifier from the given metadata object's header" do
      expect(psu_rr.identifier).to eq 'the-identifier'
    end
  end

  describe '#any_user_matches?' do
    context "when none of the creators from the given metadata match any users" do
      it "returns false" do
        expect(psu_rr.any_user_matches?).to eq false
      end
    end
    context "when one of the creators from the given metadata matches a user" do
      let(:um2) { double 'user' }
      it "returns true" do
        expect(psu_rr.any_user_matches?).to eq true
      end
    end
    context "when one of the creators from the given metadata matches more than one user" do
      let(:aum2) { [double('user1'), double('user2')] }
      it "returns true" do
        expect(psu_rr.any_user_matches?).to eq true
      end
    end
  end

  describe 'importable?' do
    context "when the value of the source attribute from the given metadata is 'Penn State Journal of Law & International Affairs'" do
      context "when none of the creators from the given metadata match any users" do
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches a user" do
        let(:um2) { double 'user' }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
      context "when one of the creators from the given metadata matches more than one user" do
        let(:aum2) { [double('user1'), double('user2')] }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
    end

    context "when the value of the source attribute from the given meatadata is 'Journal Articles'" do
      let(:metadata_xml_fixture) { File.read(Rails.root.join('spec', 'fixtures', 'oai_record_metadata2.xml')) }

      context "when none of the creators from the given metadata match any users" do
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches a user" do
        let(:um2) { double 'user' }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
      context "when one of the creators from the given metadata matches more than one user" do
        let(:aum2) { [double('user1'), double('user2')] }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
    end

    context "when the value of the source attribute from the given meatadata is 'Penn State International Law Review'" do
      let(:metadata_xml_fixture) { File.read(Rails.root.join('spec', 'fixtures', 'oai_record_metadata3.xml')) }

      context "when none of the creators from the given metadata match any users" do
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches a user" do
        let(:um2) { double 'user' }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
      context "when one of the creators from the given metadata matches more than one user" do
        let(:aum2) { [double('user1'), double('user2')] }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
    end

    context "when the value of the source attribute from the given meatadata is 'Arbitration Law Review'" do
      let(:metadata_xml_fixture) { File.read(Rails.root.join('spec', 'fixtures', 'oai_record_metadata4.xml')) }

      context "when none of the creators from the given metadata match any users" do
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches a user" do
        let(:um2) { double 'user' }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
      context "when one of the creators from the given metadata matches more than one user" do
        let(:aum2) { [double('user1'), double('user2')] }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
    end

    context "when the value of the source attribute from the given meatadata is 'Faculty Scholarly Works'" do
      let(:metadata_xml_fixture) { File.read(Rails.root.join('spec', 'fixtures', 'oai_record_metadata5.xml')) }

      context "when none of the creators from the given metadata match any users" do
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches a user" do
        let(:um2) { double 'user' }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
      context "when one of the creators from the given metadata matches more than one user" do
        let(:aum2) { [double('user1'), double('user2')] }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
    end

    context "when the value of the source attribute from the given meatadata is 'Dickinson Law Review'" do
      let(:metadata_xml_fixture) { File.read(Rails.root.join('spec', 'fixtures', 'oai_record_metadata6.xml')) }

      context "when none of the creators from the given metadata match any users" do
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches a user" do
        let(:um2) { double 'user' }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
      context "when one of the creators from the given metadata matches more than one user" do
        let(:aum2) { [double('user1'), double('user2')] }
        it "returns true" do
          expect(psu_rr.importable?).to eq true
        end
      end
    end

    context "when the value of the source attribute from the given meatadata is 'Other'" do
      let(:metadata_xml_fixture) { File.read(Rails.root.join('spec', 'fixtures', 'oai_record_metadata7.xml')) }

      context "when none of the creators from the given metadata match any users" do
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches a user" do
        let(:um2) { double 'user' }
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
      context "when one of the creators from the given metadata matches more than one user" do
        let(:aum2) { [double('user1'), double('user2')] }
        it "returns false" do
          expect(psu_rr.importable?).to eq false
        end
      end
    end
  end
end
