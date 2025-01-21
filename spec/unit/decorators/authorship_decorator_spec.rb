# frozen_string_literal: true

require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/decorators/base_decorator'
require_relative '../../../app/decorators/authorship_decorator'

describe AuthorshipDecorator do
  let(:auth) { double 'authorship',
                      title: title,
                      published_by: publisher,
                      year: year,
                      preferred_open_access_url: url,
                      scholarsphere_upload_pending?: pending,
                      activity_insight_upload_processing?: in_activity_insight,
                      scholarsphere_upload_failed?: failed,
                      open_access_waived?: waived,
                      no_open_access_information?: no_info,
                      is_oa_publication?: true,
                      publication: pub,
                      published?: published,
                      confirmed: confirmed,
                      user: user }
  let(:title) { '' }
  let(:publisher) { '' }
  let(:year) { '' }
  let(:url) { '' }
  let(:pending) { false }
  let(:failed) { false }
  let(:waived) { false }
  let(:in_activity_insight) { false }
  let(:no_info) { true }
  let(:pub) { double 'publication' }
  let(:context) { double 'view context' }
  let(:published) { true }
  let(:confirmed) { true }
  let(:ad) { described_class.new(auth, context) }
  let(:user) { double 'user' }

  before do
    allow(context).to receive(:edit_open_access_publication_path).with(pub).and_return 'the pub path'
    allow(context).to receive(:link_to).with(title, 'the pub path').and_return 'the pub link'
  end

  describe '#label' do
    context 'when the given object has an open access URL' do
      let(:url) { 'https://example.org/pubs/1' }

      context 'when the given objet has a title' do
        let(:title) { 'Test Title' }

        context 'when the given object has a publisher' do
          let(:publisher) { 'A Journal' }

          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with a publication link, publisher, and year' do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with a publication link and publisher' do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, <span class="journal-name">A Journal</span>}
            end
          end
        end

        context 'when the given object does not have a publisher' do
          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with a publication link and year' do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with a publication link' do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>}
            end
          end
        end
      end
    end

    context 'when the given object does not have an open access URL' do
      context 'when the given objet has a title' do
        let(:title) { 'Test Title' }

        context 'when the given object has a publisher' do
          let(:publisher) { 'A Journal' }

          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with a publication title, publisher, and year' do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with a publication title and publisher' do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>}
            end
          end
        end

        context 'when the given object does not have a publisher' do
          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with a publication title and year' do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with a publication title' do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>}
            end
          end
        end
      end
    end
  end

  describe '#profile_management_label' do
    context 'when the given object has open access information' do
      let(:no_info) { false }

      context 'when the given object has a title' do
        let(:title) { 'Test Title' }

        context 'when the given object has a publisher' do
          let(:publisher) { 'A Journal' }

          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with the publication title, publisher, and year' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with the publication title and publisher' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>}
            end
          end
        end

        context 'when the given object does not have a publisher' do
          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with the publication title and year' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with the publication title' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>}
            end
          end
        end
      end
    end

    context 'when the given object does not have open access information' do
      context 'when the given objet has a title' do
        let(:title) { 'Test Title' }

        context 'when the given object has a publisher' do
          let(:publisher) { 'A Journal' }

          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with a publication link, publisher, and year' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with a publication link and publisher' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>, <span class="journal-name">A Journal</span>}
            end
          end
        end

        context 'when the given object does not have a publisher' do
          context 'when the given object has a year' do
            let(:year) { 2000 }

            it 'returns a label for the given object with a publication link and year' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>, 2000}
            end
          end

          context 'when the given object does not have a year' do
            it 'returns a label for the given object with a publication link' do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>}
            end
          end
        end
      end
    end

    context 'when the given object is not a journal article' do
      context 'when the given object has a title' do
        let(:title) { 'Test Title' }

        before { allow(auth).to receive(:is_oa_publication?).and_return false }

        it 'returns a label for the given object with the publication title' do
          expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>}
        end
      end
    end

    context 'when the given object is not published' do
      context 'when the given object has a title' do
        let(:title) { 'Test Title' }
        let(:published) { false }

        it 'returns a label without a link for the given object with the publication title' do
          expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>}
        end
      end
    end

    context 'when the given object is not confirmed' do
      context 'when the given object has a title' do
        let(:title) { 'Test Title' }
        let(:confirmed) { false }

        it 'returns a label without a link for the given object with the publication title' do
          expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>}
        end
      end
    end
  end

  describe '#open_access_status_icon' do
    context 'when the given object is published' do
      context 'when the given object does not have an open access URL' do
        context 'when the given object does not have a failed ScholarSphere upload' do
          context 'when the given object does not have a pending ScholarSphere upload' do
            context 'when the given object does not have an open access waiver' do
              it "returns 'question'" do
                expect(ad.open_access_status_icon).to eq 'question'
              end
            end

            context 'when the given object has an open access waiver' do
              let(:waived) { true }

              it "returns 'lock'" do
                expect(ad.open_access_status_icon).to eq 'lock'
              end
            end
          end

          context 'when the given object has a pending ScholarSphere upload' do
            let(:pending) { true }

            context 'when the given object does not have an open access waiver' do
              it "returns 'hourglass-half'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end

            context 'when the given object has an open access waiver' do
              let(:waived) { true }

              it "returns 'hourglass-half'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end
          end

          context 'when the given object has been added to Activity Insight and is being processed' do
            let(:in_activity_insight) { true }

            it "returns 'upload'" do
              expect(ad.open_access_status_icon).to eq 'upload'
            end
          end
        end

        context 'when the given object has a failed ScholarSphere upload' do
          let(:failed) { true }

          context 'when the given object does not have a pending ScholarSphere upload' do
            context 'when the given object does not have an open access waiver' do
              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'exclamation-circle'
              end
            end

            context 'when the given object has an open access waiver' do
              let(:waived) { true }

              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'exclamation-circle'
              end
            end
          end

          context 'when the given object has a pending ScholarSphere upload' do
            let(:pending) { true }

            context 'when the given object does not have an open access waiver' do
              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end

            context 'when the given object has an open access waiver' do
              let(:waived) { true }

              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end
          end
        end
      end

      context 'when the given object has an open access URL' do
        let(:url) { 'a_url' }

        context 'when the given object does not have a failed ScholarSphere upload' do
          context 'when the given object does not have a pending ScholarSphere upload' do
            context 'when the given object does not have an open access waiver' do
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end

            context 'when the given object has an open access waiver' do
              let(:waived) { true }

              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end
          end

          context 'when the given object has a pending ScholarSphere upload' do
            let(:pending) { true }

            context 'when the given object does not have an open access waiver' do
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end

            context 'when the given object has an open access waiver' do
              let(:waived) { true }

              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end
          end

          context 'when the given object has a failed ScholarSphere upload' do
            let(:failed) { true }

            context 'when the given object does not have a pending ScholarSphere upload' do
              context 'when the given object does not have an open access waiver' do
                it "returns 'unlock-alt'" do
                  expect(ad.open_access_status_icon).to eq 'unlock-alt'
                end
              end

              context 'when the given object has an open access waiver' do
                let(:waived) { true }

                it "returns 'unlock-alt'" do
                  expect(ad.open_access_status_icon).to eq 'unlock-alt'
                end
              end
            end

            context 'when the given object has a pending ScholarSphere upload' do
              let(:pending) { true }

              context 'when the given object does not have an open access waiver' do
                it "returns 'unlock-alt'" do
                  expect(ad.open_access_status_icon).to eq 'unlock-alt'
                end
              end

              context 'when the given object has an open access waiver' do
                let(:waived) { true }

                it "returns 'unlock-alt'" do
                  expect(ad.open_access_status_icon).to eq 'unlock-alt'
                end
              end
            end
          end
        end
      end
    end

    context 'when the given object is not published' do
      let(:published) { false }

      it "returns 'circle-o-notch'" do
        expect(ad.open_access_status_icon).to eq 'circle-o-notch'
      end
    end
  end

  describe '#open_access_status_icon_alt_text' do
    context 'when the icon is unlock-alt' do
      before { allow(ad).to receive(:open_access_status_icon).and_return('unlock-alt') }

      it 'returns the correct alt text' do
        expect(ad.open_access_status_icon_alt_text).to eq 'known open access version'
      end
    end

    context 'when the icon is lock' do
      before { allow(ad).to receive(:open_access_status_icon).and_return('lock') }

      it 'returns the correct alt text' do
        expect(ad.open_access_status_icon_alt_text).to eq 'Open access obligations waived'
      end
    end

    context 'when the icon is hourglass-half' do
      before { allow(ad).to receive(:open_access_status_icon).and_return('hourglass-half') }

      it 'returns the correct alt text' do
        expect(ad.open_access_status_icon_alt_text).to eq 'Upload to ScholarSphere pending'
      end
    end

    context 'when the icon is exclamation-circle' do
      before { allow(ad).to receive(:open_access_status_icon).and_return('exclamation-circle') }

      it 'returns the correct alt text' do
        expect(ad.open_access_status_icon_alt_text).to eq 'Scholarsphere upload failed. Please try again'
      end
    end

    context 'when the icon is circle-o-notch' do
      before { allow(ad).to receive(:open_access_status_icon).and_return('circle-o-notch') }

      it 'returns the correct alt text' do
        expect(ad.open_access_status_icon_alt_text).to eq 'Publication is in press and will not be subject to the open access policy until published'
      end
    end

    context 'when the icon is question' do
      before { allow(ad).to receive(:open_access_status_icon).and_return('question') }

      it 'returns the correct alt text' do
        expect(ad.open_access_status_icon_alt_text).to eq 'open access status currently unknown. Click publication title link to add information or submit a waiver'
      end
    end
  end

  context 'when the icon is "upload"' do
    before { allow(ad).to receive(:open_access_status_icon).and_return('upload') }

    it 'returns the correct alt text' do
      expect(ad.open_access_status_icon_alt_text).to eq 'A file for the publication was uploaded in Activity Insight and is being processed for deposit in ScholarSphere.'
    end
  end

  describe 'exportable_to_orcid?' do
    context "when the authorship's user has an ORCiD access token" do
      before { allow(user).to receive(:orcid_access_token).and_return 'token' }

      context "when the authorship's publication can be exported to ORCiD" do
        before { allow(pub).to receive(:orcid_allowed?).and_return true }

        context 'when the authorship is confirmed' do
          it 'returns true' do
            expect(ad.exportable_to_orcid?).to be true
          end
        end

        context 'when the authorship is not confirmed' do
          let(:confirmed) { false }

          it 'returns false' do
            expect(ad.exportable_to_orcid?).to be false
          end
        end
      end

      context "when the authorship's publication cannot be exported to ORCiD" do
        before { allow(pub).to receive(:orcid_allowed?).and_return false }

        context 'when the authorship is confirmed' do
          it 'returns false' do
            expect(ad.exportable_to_orcid?).to be false
          end
        end

        context 'when the authorship is not confirmed' do
          let(:confirmed) { false }

          it 'returns false' do
            expect(ad.exportable_to_orcid?).to be false
          end
        end
      end
    end

    context "when the authorship's user does not have an ORCiD access token" do
      before { allow(user).to receive(:orcid_access_token).and_return(nil) }

      context "when the authorship's publication can be exported to ORCiD" do
        before { allow(pub).to receive(:orcid_allowed?).and_return true }

        context 'when the authorship is confirmed' do
          it 'returns false' do
            expect(ad.exportable_to_orcid?).to be false
          end
        end

        context 'when the authorship is not confirmed' do
          let(:confirmed) { false }

          it 'returns false' do
            expect(ad.exportable_to_orcid?).to be false
          end
        end
      end

      context "when the authorship's publication cannot be exported to ORCiD" do
        before { allow(pub).to receive(:orcid_allowed?).and_return false }

        context 'when the authorship is confirmed' do
          it 'returns false' do
            expect(ad.exportable_to_orcid?).to be false
          end
        end

        context 'when the authorship is not confirmed' do
          let(:confirmed) { false }

          it 'returns false' do
            expect(ad.exportable_to_orcid?).to be false
          end
        end
      end
    end
  end
end
