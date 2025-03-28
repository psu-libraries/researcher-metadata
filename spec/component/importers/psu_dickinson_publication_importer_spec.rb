# frozen_string_literal: true

# rubocop:disable RSpec/AnyInstance

require 'component/component_spec_helper'

describe PSUDickinsonPublicationImporter do
  let(:importer) { described_class.new }

  let(:dickinson_law_repo) { double 'fieldhand repository for Dickinson Law' }
  let(:records) { [record1, record2, record3] }
  let(:record1) { double 'fieldhand OAI record 1' }
  let(:record2) { double 'fieldhand OAI record 2' }
  let(:record3) { double 'fieldhand OAI record 3' }

  let(:r1) { double 'record 1', any_user_matches?: false }
  let(:r2) { double 'record 2',
                    any_user_matches?: true,
                    identifier: 'existing-identifier',
                    publisher: 'Test Publisher',
                    source: 'Test Source',
                    url: 'https://example.com/article' }
  let(:r3) { double 'record 3',
                    any_user_matches?: true,
                    identifier: 'non-existing-identifier',
                    title: 'A Penn State Law Article',
                    description: 'a description of the article',
                    date: Date.new(2020, 1, 1),
                    publisher: 'The Publisher',
                    source: 'The Source',
                    url: 'https://example.com/article',
                    creators: [c1, c2] }

  let(:c1) { double 'creator 1',
                    first_name: 'First',
                    last_name: 'Creator',
                    user_match: u1,
                    ambiguous_user_matches: [] }
  let(:c2) { double 'creator 2',
                    first_name: 'Second',
                    last_name: 'Author',
                    user_match: nil,
                    ambiguous_user_matches: [u2, u3] }

  let!(:u1) { create(:user) }
  let!(:u2) { create(:user) }
  let!(:u3) { create(:user) }

  let!(:existing_import) { create(:publication_import,
                                  source: 'Dickinson Law IDEAS Repo',
                                  source_identifier: 'existing-identifier') }

  before do
    allow(Fieldhand::Repository).to receive(:new).with('https://ideas.dickinsonlaw.psu.edu/do/oai').and_return dickinson_law_repo
    allow(dickinson_law_repo).to receive(:records).with(metadata_prefix: 'dcs', set: 'publication:fac-works').and_return records
    allow(PSULawSchoolOAIRepoRecord).to receive(:new).with(record1).and_return r1
    allow(PSULawSchoolOAIRepoRecord).to receive(:new).with(record2).and_return r2
    allow(PSULawSchoolOAIRepoRecord).to receive(:new).with(record3).and_return r3
    allow(DOIVerificationJob).to receive(:perform_later)
  end

  describe '#call' do
    it "saves new imports for records that are importable and that don't already exist" do
      expect { importer.call }.to change(PublicationImport, :count).by 1
    end

    it "creates new publications for records that are importable and that don't already exist" do
      expect { importer.call }.to change(Publication, :count).by 1
    end

    it "creates new authorships for records that are importable and that don't already exist" do
      expect { importer.call }.to change(Authorship, :count).by 3
    end

    it "creates new contributor names for records that are importable and that don't already exist" do
      expect { importer.call }.to change(ContributorName, :count).by 2
    end

    it 'creates new open access locations for records that are importable' do
      expect { importer.call }.to change(OpenAccessLocation, :count).by 2
    end

    it 'is idempotent in terms of creating publication imports' do
      importer.call
      expect { importer.call }.not_to change(PublicationImport, :count)
    end

    it 'is idempotent in terms of creating publications' do
      importer.call
      expect { importer.call }.not_to change(Publication, :count)
    end

    it 'is idempotent in terms of creating authorships' do
      importer.call
      expect { importer.call }.not_to change(Authorship, :count)
    end

    it 'is idempotent in terms of creating contributor names' do
      importer.call
      expect { importer.call }.not_to change(ContributorName, :count)
    end

    it 'is idempotent in terms of creating open access locations' do
      importer.call
      expect { importer.call }.not_to change(OpenAccessLocation, :count)
    end

    it 'saves the correct metadata' do
      importer.call
      import = PublicationImport.find_by(source: 'Dickinson Law IDEAS Repo',
                                         source_identifier: 'non-existing-identifier')

      pub = import.publication
      expect(pub.title).to eq 'A Penn State Law Article'
      expect(pub.abstract).to eq 'a description of the article'
      expect(pub.published_on).to eq Date.new(2020, 1, 1)
      expect(pub.publisher_name).to eq 'The Publisher'
      expect(pub.publication_type).to eq 'Journal Article'
      expect(pub.status).to eq 'Published'
      expect(pub.journal_title).to eq 'The Source'

      con1 = pub.contributor_names.find_by(first_name: 'First')
      expect(con1.last_name).to eq 'Creator'
      expect(con1.position).to eq 1
      expect(con1.user).to eq u1

      con2 = pub.contributor_names.find_by(first_name: 'Second')
      expect(con2.last_name).to eq 'Author'
      expect(con2.position).to eq 2

      auth1 = pub.authorships.find_by(user: u1)
      expect(auth1.author_number).to eq 1
      expect(auth1.confirmed).to be true

      auth2 = pub.authorships.find_by(user: u2)
      expect(auth2.author_number).to eq 2
      expect(auth2.confirmed).to be false

      auth3 = pub.authorships.find_by(user: u3)
      expect(auth3.author_number).to eq 2
      expect(auth3.confirmed).to be false

      oal = pub.open_access_locations.find_by(source: Source::DICKINSON_IDEAS)
      expect(oal.url).to eq 'https://example.com/article'
    end

    context 'when there are duplicate records' do
      let!(:duplicate_pub) { create(:publication, title: 'A Penn State Law Article') }

      before do
        allow_any_instance_of(DuplicatePublicationGroup).to receive_messages(auto_merge: nil, auto_merge_matching: nil)
      end

      it 'calls the auto-merge methods' do
        expect_any_instance_of(DuplicatePublicationGroup).to receive(:auto_merge)
        expect_any_instance_of(DuplicatePublicationGroup).to receive(:auto_merge_matching)
        importer.call
      end

      it 'groups duplicates of new publication records' do
        expect { importer.call }.to change(DuplicatePublicationGroup, :count).by 1
        import = PublicationImport.find_by(source: 'Dickinson Law IDEAS Repo',
                                           source_identifier: 'non-existing-identifier')
        pub = import.publication

        group = pub.duplicate_group

        expect(group.publications).to contain_exactly(pub, duplicate_pub)
      end

      it 'hides new publications that might be duplicates' do
        importer.call

        import = PublicationImport.find_by(source: 'Dickinson Law IDEAS Repo',
                                           source_identifier: 'non-existing-identifier')
        pub = import.publication
        expect(pub.visible).to be false
      end
    end

    it 'runs the DOI verification' do
      importer.call
      pub_import = PublicationImport.find_by(source: 'Dickinson Law IDEAS Repo',
                                             source_identifier: 'non-existing-identifier').publication
      expect(DOIVerificationJob).to have_received(:perform_later).with(pub_import.id)
    end

    it 'returns nil' do
      expect(importer.call).to be_nil
    end
  end
end
# rubocop:enable RSpec/AnyInstance
