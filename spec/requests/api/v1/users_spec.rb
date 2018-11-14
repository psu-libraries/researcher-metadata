require 'requests/requests_spec_helper'

describe 'API::V1 Users' do

  describe 'GET /v1/users/:webaccess_id/presentations' do
    let!(:user) { create(:user_with_presentations, webaccess_id: 'xyz321', presentations_count: 10) }
    let!(:invisible_presentation) {
      user.presentations.create(
        activity_insight_identifier: 'abc123',
        visible: false
      )
    }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      get "/v1/users/#{webaccess_id}/presentations#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has presentations" do
        it "returns all the user's visible presentations" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has no presentations" do
        let(:user_without_visible_presentations) { create(:user, webaccess_id: "nopres123") }
        let(:webaccess_id) { user_without_visible_presentations.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/contracts' do
    let!(:user) { create(:user_with_contracts, webaccess_id: 'xyz321', contracts_count: 10) }
    let!(:invisible_contract) { create :contract, visible: false }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      create :user_contract, user: user, contract: invisible_contract
      get "/v1/users/#{webaccess_id}/contracts#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has contracts" do
        it "returns all the user's contracts" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has no contracts" do
        let(:user_without_contracts) { create(:user, webaccess_id: "nocons123") }
        let(:webaccess_id) { user_without_contracts.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/news_feed_items' do
    let!(:user) { create(:user_with_news_feed_items, webaccess_id: 'xyz321', news_feed_items_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      get "/v1/users/#{webaccess_id}/news_feed_items#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has news feed items" do
        it "returns all the user's news feed items" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has no news feed itemss" do
        let(:user_without_news_feed_items) { create(:user, webaccess_id: "nocons123") }
        let(:webaccess_id) { user_without_news_feed_items.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/publications' do
    let!(:user) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let!(:invisible_pub) { create :publication, visible: false }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      create :authorship, user: user, publication: invisible_pub
      get "/v1/users/#{webaccess_id}/publications#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user has publications" do
        it "returns all the user's visible publications" do
          expect(json_response[:data].size).to eq(10)
        end
        describe 'params:' do
          describe 'limit' do
            let(:params) { "?limit=5"}
            it "returns the specified number of publications" do
              expect(json_response[:data].size).to eq(5)
            end
          end
        end
      end
      context "when the user has no publications" do
        let(:user_without_publications) { create(:user, webaccess_id: "nopubs123") }
        let(:webaccess_id) { user_without_publications.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
    end
  end

  describe 'POST /v1/users/publications' do
    let!(:user_xyz123) { create(:user_with_authorships, webaccess_id: 'xyz321', authorships_count: 10) }
    let!(:user_abc123) { create(:user_with_authorships, webaccess_id: 'abc123', authorships_count: 5) }

    let!(:user_cws161) { create(:user, webaccess_id: 'cws161') }

    let!(:invisible_pub1) { create :publication, visible: false }
    let!(:invisible_pub2) { create :publication, visible: false }

    before do
      create :authorship, user: user_abc123, publication: invisible_pub1
      create :authorship, user: user_cws161, publication: invisible_pub2

      post "/v1/users/publications", params: params
    end
    context "for a valid set of webaccess_id params" do
      let(:params) { { '_json': %w(abc123 xyz321 cws161 fake123) } }
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      it "returns visible publications for each webaccess_id" do
        expect(json_response.count).to eq(3)
        expect(json_response[:abc123][:data].count).to eq(5)
        expect(json_response[:xyz321][:data].count).to eq(10)
        expect(json_response[:cws161][:data].count).to eq(0)
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/etds' do
    let!(:user) { create(:user_with_committee_memberships, webaccess_id: 'xyz321', committee_memberships_count: 10) }
    let(:webaccess_id) { user.webaccess_id }
    let(:params) { '' }
    let(:headers) { { "accept" => "application/json" } }

    before do
      get "/v1/users/#{webaccess_id}/etds#{params}", headers: headers
    end

    context "for a valid webaccess_id" do
      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end
      context "when the user served on etd committees" do
        it "returns all the etds the user was a committee member on" do
          expect(json_response[:data].size).to eq(10)
        end
      end
      context "when the user has not served on any committees" do
        let(:user_without_etds) { create(:user, webaccess_id: "nocommittees123") }
        let(:webaccess_id) { user_without_etds.webaccess_id }
        it "returns an empty JSON data hash" do
          expect(json_response[:data].size).to eq(0)
        end
      end
      context "when an html-formatted response is requested" do
        let(:headers) { { "accept" => "text/html" } }
        it 'returns HTTP status 200' do
          expect(response).to have_http_status 200
        end
      end
    end
    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }
      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
    end
  end

  describe 'GET /v1/users/:webaccess_id/profile' do
    let!(:user) { create(:user,
                         first_name: "Bob",
                         last_name: "Testerson",
                         webaccess_id: 'bat123') }
    let(:headers) { { "accept" => "text/html" } }

    context "for a valid webaccess_id" do
      before do
        get "/v1/users/#{webaccess_id}/profile", headers: headers
      end

      let(:webaccess_id) { 'bat123' }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      context "when the user has no associated metadata" do
        it "returns an HTML representation of the given user's basic information" do
          expect(response.body).to eq <<~HTML
              <h2 id="md-full-name">Bob Testerson</h2>
              <div id="md-person-info">
                <ul>
                  <li>Email:  <a href="mailto:bat123@psu.edu">bat123@psu.edu</a></li>
                </ul>
              </div>
            HTML
        end
      end

      context "when the user has associated metadata" do
        let!(:pub1) { create :publication, title: "First Publication",
                             visible: true,
                             journal_title: "Test Journal",
                             published_on: Date.new(2010, 1, 1) }
        let!(:pub2) { create :publication, title: "Second Publication",
                             visible: true,
                             publisher: "Test Publisher",
                             published_on: Date.new(2015, 1, 1) }
        let!(:pub3) { create :publication, title: "Third Publication",
                             visible: true,
                             published_on: Date.new(2018, 1, 1) }
        let!(:pub4) { create :publication, title: "Undated Publication",
                             visible: true }
        let!(:pub5) { create :publication,
                             title: "Invisible Publication",
                             visible: false }

        let!(:con1) { create :contract,
                             contract_type: "Contract",
                             status: "Awarded",
                             title: "Awarded Contract",
                             visible: true }
        let!(:con2) { create :contract,
                             contract_type: "Grant",
                             status: "Pending",
                             title: "Pending Grant",
                             visible: true }
        let!(:con3) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Awarded Grant One",
                             sponsor: "Test Sponsor",
                             award_start_on: Date.new(2010, 1, 1),
                             award_end_on: Date.new(2010, 5, 1),
                             visible: true }
        let!(:con4) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Awarded Grant Two",
                             sponsor: "Other Sponsor",
                             award_start_on: Date.new(2015, 2, 1),
                             award_end_on: Date.new(2016, 1, 1),
                             visible: true }
        let!(:con5) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Awarded Grant Three",
                             sponsor: "Sponsor",
                             award_start_on: nil,
                             visible: true }
        let!(:con6) { create :contract,
                             contract_type: "Grant",
                             status: "Awarded",
                             title: "Invisible Awarded Grant",
                             visible: false }

        let!(:pres1) { create :presentation,
                              name: "Presentation Two",
                              organization: "An Organization",
                              location: "Earth"}
        let!(:pres2) { create :presentation,
                              title: nil,
                              name: nil }

        let!(:etd1) { create :etd, title: 'ETD\n One',
                             url: "test.edu" }

        let!(:nfi1) { create :news_feed_item,
                             user: user,
                             title: "Story One",
                             url: "news.edu/1",
                             published_on: Date.new(2016, 1, 2) }

        let!(:nfi2) { create :news_feed_item,
                             user: user,
                             title: "Story Two",
                             url: "news.edu/2",
                             published_on: Date.new(2018, 3, 4) }

        before do
          create :authorship, user: user, publication: pub1
          create :authorship, user: user, publication: pub2
          create :authorship, user: user, publication: pub3
          create :authorship, user: user, publication: pub4
          create :authorship, user: user, publication: pub5

          create :user_contract, user: user, contract: con1
          create :user_contract, user: user, contract: con2
          create :user_contract, user: user, contract: con3
          create :user_contract, user: user, contract: con4
          create :user_contract, user: user, contract: con5
          create :user_contract, user: user, contract: con6

          create :presentation_contribution, user: user, presentation: pres1
          create :presentation_contribution, user: user, presentation: pres2

          create :committee_membership, user: user, etd: etd1, role: "Committee Member"

          get "/v1/users/#{webaccess_id}/profile", headers: headers
        end

        it "returns an HTML representation of all of the given user's available metadata" do
          expect(response.body).to eq <<~HTML
            <h2 id="md-full-name">Bob Testerson</h2>
            <div id="md-person-info">
              <ul>
                <li>Email:  <a href="mailto:bat123@psu.edu">bat123@psu.edu</a></li>
              </ul>
            </div>
              <div id="md-publications">
                <h3>Publications</h3>
                <ul>
                    <li>Undated Publication</li>
                    <li>Third Publication, 2018</li>
                    <li>Second Publication, Test Publisher, 2015</li>
                    <li>First Publication, Test Journal, 2010</li>
                </ul>
              </div>
              <div id="md-grants">
                <h3>Grants</h3>
                <ul>
                    <li>Awarded Grant Three, Sponsor</li>
                    <li>Awarded Grant Two, Other Sponsor, 2/2015 - 1/2016</li>
                    <li>Awarded Grant One, Test Sponsor, 1/2010 - 5/2010</li>
                </ul>
              </div>
              <div id="md-presentations">
                <h3>Presentations</h3>
                <ul>
                      <li>Presentation Two, An Organization, Earth</li>
                </ul>
              </div>
              <div id="md-advising">
                <h3>Graduate Student Advising</h3>
                <ul>
                    <li><a href="test.edu">ETD  One</a> (Committee Member)</li>
                </ul>
              </div>
              <div id="md-news-stories">
                <h3>Penn State News Media Mentions</h3>
                <ul>
                    <li><a href="news.edu/2" target="_blank">Story Two</a> 3/4/2018</li>
                    <li><a href="news.edu/1" target="_blank">Story One</a> 1/2/2016</li>
                </ul>
              </div>
            HTML
        end
      end
    end

    context "for an invalid webaccess_id" do
      let(:webaccess_id) { "aaa" }

      before do
        get "/v1/users/#{webaccess_id}/profile", headers: headers
      end

      it "returns 404 not found" do
        expect(response).to have_http_status 404
      end
    end
  end
end
