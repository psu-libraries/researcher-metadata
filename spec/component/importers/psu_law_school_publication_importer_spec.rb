require 'component/component_spec_helper'

describe PSULawSchoolPublicationImporter do
  let(:importer) { PSULawSchoolPublicationImporter.new }

  let(:psu_law_repo) { double 'fieldhand repository for PSU Law School', records: records }
  let(:records) { [record1, record2, record3] }
  let(:record1) { double 'fieldhand OAI record 1' }
  let(:record2) { double 'fieldhand OAI record 2' }
  let(:record3) { double 'fieldhand OAI record 3' }

  let(:r1) { double 'record 1', importable?: false }
  let(:r2) { double 'record 2',
                    importable?: true,
                    identifier: 'existing-identifier' }
  let(:r3) { double 'record 3',
                    importable?: true,
                    identifier: 'non-existing-identifier',
                    title: 'A Penn State Law Article',
                    description: 'a description of the article',
                    date: Date.new(2020, 1, 1),
                    publisher: 'The Publisher',
                    url1: 'https://example.com/article',
                    url2: 'https://example.com/article/download',
                    creators: [c1, c2] }

  let(:c1) { double 'creator 1',
                    first_name: "First",
                    last_name: "Creator",
                    user_match: u1,
                    ambiguous_user_matches: [] }
  let(:c2) { double 'creator 2',
                    first_name: "Second",
                    last_name: "Author",
                    user_match: nil,
                    ambiguous_user_matches: [u2, u3] }

  let!(:u1) { create :user }
  let!(:u2) { create :user }
  let!(:u3) { create :user }

  let!(:existing_import) { create :publication_import,
                                  source: 'Penn State Law eLibrary Repo',
                                  source_identifier: 'existing-identifier' }

  let!(:duplicate_pub) { create :publication, title: 'A Penn State Law Article' }

  before do
    allow(Fieldhand::Repository).to receive(:new).with('https://elibrary.law.psu.edu/do/oai').and_return psu_law_repo
    allow(PSULawSchoolOAIRepoRecord).to receive(:new).with(record1).and_return r1
    allow(PSULawSchoolOAIRepoRecord).to receive(:new).with(record2).and_return r2
    allow(PSULawSchoolOAIRepoRecord).to receive(:new).with(record3).and_return r3
  end

  describe "#call" do
    it "saves new imports for records that are importable and that don't already exist" do
      expect { importer.call }.to change { PublicationImport.count }.by 1
    end

    it "creates new publications for records that are importable and that don't already exist" do
      expect { importer.call }.to change { Publication.count }.by 1
    end

    it "creates new authorships for records that are importable and that don't already exist" do
      expect { importer.call }.to change { Authorship.count }.by 3
    end

    it "creates new contributors for records that are importable and that don't already exist" do
      expect { importer.call }.to change { Contributor.count }.by 2
    end

    it "is idempotent in terms of creating publication imports" do
      importer.call
      expect { importer.call }.not_to change { PublicationImport.count }
    end

    it "is idempotent in terms of creating publications" do
      importer.call
      expect { importer.call }.not_to change { Publication.count }
    end

    it "is idempotent in terms of creating authorships" do
      importer.call
      expect { importer.call }.not_to change { Authorship.count }
    end

    it "is idempotent in terms of creating contributors" do
      importer.call
      expect { importer.call }.not_to change { Contributor.count }
    end

    it "saves the correct metadata" do
      importer.call
      import = PublicationImport.find_by(source: 'Penn State Law eLibrary Repo',
                                         source_identifier: 'non-existing-identifier')

      pub = import.publication
      expect(pub.title).to eq 'A Penn State Law Article'
      expect(pub.abstract).to eq 'a description of the article'
      expect(pub.published_on).to eq Date.new(2020, 1, 1)
      expect(pub.publisher_name).to eq 'The Publisher'
      expect(pub.url).to eq 'https://example.com/article'
      expect(pub.open_access_url).to eq 'https://example.com/article/download'
      expect(pub.publication_type).to eq 'Journal Article'
      expect(pub.status).to eq 'Published'

      con1 = pub.contributors.find_by(first_name: 'First')
      expect(con1.last_name).to eq 'Creator'
      expect(con1.position).to eq 1

      con2 = pub.contributors.find_by(first_name: 'Second')
      expect(con2.last_name).to eq 'Author'
      expect(con2.position).to eq 2

      auth1 = pub.authorships.find_by(user: u1)
      expect(auth1.author_number).to eq 1
      expect(auth1.confirmed).to eq true

      auth2 = pub.authorships.find_by(user: u2)
      expect(auth2.author_number).to eq 2
      expect(auth2.confirmed).to eq false

      auth3 = pub.authorships.find_by(user: u3)
      expect(auth3.author_number).to eq 2
      expect(auth3.confirmed).to eq false
    end

    it "groups duplicates of new publication records" do
      expect { importer.call }.to change { DuplicatePublicationGroup.count }.by 1

      import = PublicationImport.find_by(source: 'Penn State Law eLibrary Repo',
                                         source_identifier: 'non-existing-identifier')
      pub = import.publication

      group = pub.duplicate_group

      expect(group.publications).to match_array [pub, duplicate_pub]
    end

    it "hides new publications that might be duplicates" do
      importer.call

      import = PublicationImport.find_by(source: 'Penn State Law eLibrary Repo',
                                         source_identifier: 'non-existing-identifier')
      pub = import.publication

      expect(pub.visible).to eq false
    end

    it "returns nil" do
      expect(importer.call).to eq nil
    end
  end
end
