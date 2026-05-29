# frozen_string_literal: true

require 'integration/integration_spec_helper'
require 'component/component_spec_helper'

require 'integration/profiles/shared_examples_for_profile_management_page'

describe 'visiting the page to edit the open access status of a publication', type: :feature do
  let(:user) { create(:user, webaccess_id: 'xyz123', first_name: 'Robert', last_name: 'Author') }
  let(:pub) { create(:publication,
                     title: 'Test Publication',
                     secondary_title: 'The Subtitle',
                     issue: '583',
                     volume: '971',
                     page_range: '478-483',
                     published_on: Date.new(2019, 3, 17),
                     doi: 'https://doi.org/10.1109/5.771073',
                     abstract: 'An abstract of the test publication',
                     journal: journal) }
  let!(:auth) { create(:authorship, user: user, publication: pub) }
  let!(:journal) { create(:journal,
                          title: 'A Prestigious Journal') }
  let!(:name) { create(:contributor_name,
                       publication: pub,
                       user: user,
                       position: 1,
                       first_name: 'Bob',
                       last_name: 'Author') }
  let(:other_pub) { create(:publication) }
  let(:non_article_pub) { create(:publication,
                                 publication_type: 'Book') }
  let(:oa_pub) { create(:publication,
                        title: 'Open Access Publication',
                        journal_title: 'Open Access Journal',
                        issue: '834',
                        volume: '620',
                        page_range: '112-124',
                        published_on: Date.new(2020, 1, 1),
                        open_access_locations: [build(:open_access_location,
                                                      source: Source::OPEN_ACCESS_BUTTON,
                                                      url: 'a_url')]) }
  let(:ss_pub) { create(:publication,
                        title: 'Scholarsphere Publication',
                        journal_title: 'Another Journal',
                        issue: '54',
                        volume: '16',
                        page_range: '63-81',
                        published_on: Date.new(2018, 1, 1)) }
  let(:waived_pub) { create(:publication,
                            title: 'Waived Publication',
                            journal_title: 'Closed Access Journal',
                            issue: '89',
                            volume: '27',
                            page_range: '160-173',
                            published_on: Date.new(2017, 1, 1)) }
  let(:response) { double 'response' }

  let!(:waived_auth) { create(:authorship, user: user, publication: waived_pub) }
  let!(:ss_deposited_auth) { create(:authorship, user: user, publication: ss_pub) }
  let!(:swd) { create(:scholarsphere_work_deposit, authorship: ss_deposited_auth, status: 'Pending') }

  before do
    create(:authorship, user: user, publication: oa_pub)

    create(:authorship, user: user, publication: non_article_pub)
    create(:internal_publication_waiver, authorship: waived_auth)

    allow(HTTParty).to receive(:head).and_return(response)
    allow(response).to receive(:code).and_return 200
  end

  context 'when the user is not signed in' do
    before { visit edit_open_access_publication_path(pub) }

    it 'does not allow them to visit the page' do
      expect(page).to have_no_current_path edit_open_access_publication_path(pub), ignore_query: true
    end
  end

  context 'when the user is signed in' do
    before { authenticate_as(user) }

    context 'when requesting a publication that belongs to the user' do
      before do
        sleep 0.5
        visit edit_open_access_publication_path(pub)
      end

      it_behaves_like 'a profile management page'

      it 'shows the title of the publication' do
        expect(page).to have_content 'Test Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'A Prestigious Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '583'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '971'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '478-483'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2019'
      end

      it 'shows a link to the open access waiver' do
        expect(page).to have_link 'Waive open access obligations for this publication', href: new_internal_publication_waiver_path(pub)
      end

      describe 'clicking the Deposit button' do
        let(:ingest) { double 'scholarsphere client ingest', create: response }
        let(:response) { double 'scholarsphere client response', status: status, body: response_body }
        let(:edit_url_path) { '/some-url' }
        let(:scholarsphere_base_uri) { 'https://scholarsphere.test' }
        let(:response_body) { %{{"url": "/the-url", "edit_url": "#{edit_url_path}"}} }
        let(:status) { 201 }

        before do
          allow(Scholarsphere::Client::Ingest).to receive(:new).and_return ingest
          allow(ResearcherMetadata::Application).to receive(:scholarsphere_base_uri).and_return scholarsphere_base_uri
        end

        it 'creates a new ScholarsphereWorkDeposit' do
          initial_count = ScholarsphereWorkDeposit.count
          click_on 'Deposit to Scholarsphere'
          after_count = ScholarsphereWorkDeposit.count
          expect(after_count - initial_count).to eq(1)
          expect(ScholarsphereWorkDeposit.last.draft_scholarsphere_work_deposit_url).to eq("#{scholarsphere_base_uri}/the-url")
        end

        it 'reroutes to Scholarsphere' do
          click_on 'Deposit to Scholarsphere'
          sleep 0.1
          expect(page.current_url).to eq("#{scholarsphere_base_uri}#{edit_url_path}")
        end

        context 'if the deposit is not successful' do
          let(:status) { 500 }
          let(:response_body) { %{{"error" : "some error"}} }

          it 'displays an error message when something goes wrong' do
            click_on 'Deposit to Scholarsphere'
            expect(page).to have_content I18n.t('profile.open_access_publications.create_scholarsphere_deposit.fail')
          end

          it 'saves the failure to the ScholarsphereWorkDeposit' do
            click_on 'Deposit to Scholarsphere'
            expect(ScholarsphereWorkDeposit.last.status).to eq('Failed')
            expect(ScholarsphereWorkDeposit.last.error_message).to eq('{"error" : "some error"}')
          end
        end
      end
    end

    context 'when requesting a publication that belongs to the user and has an open access URL' do
      before { visit edit_open_access_publication_path(oa_pub) }

      it_behaves_like 'a profile management page'

      it 'shows an appropriate message' do
        expect(page).to have_content 'no further action'
      end

      it 'shows the title of the publication' do
        expect(page).to have_content 'Open Access Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'Open Access Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '834'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '620'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '112-124'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2020'
      end

      it 'shows the open access status of the publication' do
        expect(page).to have_content 'This publication is open access'
        expect(page).to have_link 'a_url', href: 'a_url'
      end
    end

    context 'when requesting a publication that belongs to the user and has a pending Scholarsphere upload' do
      before { visit edit_open_access_publication_path(ss_pub) }

      it_behaves_like 'a profile management page'

      it 'shows an appropriate message' do
        expect(page).to have_content 'no further action'
      end

      it 'shows the title of the publication' do
        expect(page).to have_content 'Scholarsphere Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'Another Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '54'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '16'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '63-81'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2018'
      end

      it 'shows the open access status of the publication' do
        expect(page).to have_content 'This publication is in the process of being added to Scholarsphere'
      end
    end

    context 'when requesting a publication that belongs to the user and has had open access waived' do
      before { visit edit_open_access_publication_path(waived_pub) }

      it_behaves_like 'a profile management page'

      it 'shows an appropriate message' do
        expect(page).to have_content 'no further action'
      end

      it 'shows the title of the publication' do
        expect(page).to have_content 'Waived Publication'
      end

      it "shows the publication's journal" do
        expect(page).to have_content 'Closed Access Journal'
      end

      it "shows the publication's issue number" do
        expect(page).to have_content '89'
      end

      it "shows the publication's volume number" do
        expect(page).to have_content '27'
      end

      it "shows the publication's page range" do
        expect(page).to have_content '160-173'
      end

      it "shows the publication's year" do
        expect(page).to have_content '2017'
      end

      it 'shows the open access status of the publication' do
        expect(page).to have_content 'Open access obligations have been waived for this publication'
      end
    end

    context 'when requesting a publication that does not belong to the user' do
      it 'returns 404' do
        visit edit_open_access_publication_path(other_pub)
        expect(page.status_code).to eq 404
      end
    end

    context 'when requesting a publication that is not a journal article' do
      it 'returns 404' do
        visit edit_open_access_publication_path(non_article_pub)
        expect(page.status_code).to eq 404
      end
    end
  end
end
