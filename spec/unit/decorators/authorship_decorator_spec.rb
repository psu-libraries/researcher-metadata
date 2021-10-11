require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/decorators/authorship_decorator'

describe AuthorshipDecorator do
  let(:auth) { double 'authorship',
                       title: title,
                       published_by: publisher,
                       year: year,
                       preferred_open_access_url: url,
                       scholarsphere_upload_pending?: pending,
                       scholarsphere_upload_failed?: failed,
                       open_access_waived?: waived,
                       no_open_access_information?: no_info,
                       is_journal_article?: true,
                       publication: pub,
                       published?: published}
  let(:title) { '' }
  let(:publisher) { '' }
  let(:year) { '' }
  let(:url) { '' }
  let(:pending) { false }
  let(:failed) { false }
  let(:waived) { false }
  let(:no_info) { true }
  let(:pub) { double 'publication' }
  let(:context) { double 'view context' }
  let(:ad) { AuthorshipDecorator.new(auth, context) }
  let(:published) { true }

  before do
    allow(context).to receive(:edit_open_access_publication_path).with(pub).and_return 'the pub path'
    allow(context).to receive(:link_to).with(title, 'the pub path').and_return 'the pub link'
  end

  describe '#class' do
    it "returns the class name of the wrapped object" do
      expect(ad.class).to eq RSpec::Mocks::Double
    end
  end

  describe "#label" do
    context "when the given object has an open access URL" do
      let(:url) { "https://example.org/pubs/1" }

      context "when the given objet has a title" do
        let(:title) { 'Test Title' }
        context "when the given object has a publisher" do
          let(:publisher) { 'A Journal' }
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication link, publisher, and year" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication link and publisher" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, <span class="journal-name">A Journal</span>}
            end
          end
        end
        context "when the given object does not have a publisher" do
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication link and year" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication link" do
              expect(ad.label).to eq %{<span class="publication-title"><a href="https://example.org/pubs/1" target="_blank">Test Title</a></span>}
            end
          end
        end
      end
    end

    context "when the given object does not have an open access URL" do
      context "when the given objet has a title" do
        let(:title) { 'Test Title' }
        context "when the given object has a publisher" do
          let(:publisher) { 'A Journal' }
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication title, publisher, and year" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication title and publisher" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>}
            end
          end
        end
        context "when the given object does not have a publisher" do
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication title and year" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication title" do
              expect(ad.label).to eq %{<span class="publication-title">Test Title</span>}
            end
          end
        end
      end
    end
  end

  describe '#profile_management_label' do
    context "when the given object has open access information" do
      let(:no_info) { false }

      context "when the given object has a title" do
        let(:title) { 'Test Title' }
        context "when the given object has a publisher" do
          let(:publisher) { 'A Journal' }
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with the publication title, publisher, and year" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with the publication title and publisher" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>, <span class="journal-name">A Journal</span>}
            end
          end
        end
        context "when the given object does not have a publisher" do
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with the publication title and year" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with the publication title" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>}
            end
          end
        end
      end
    end

    context "when the given object does not have open access information" do
      context "when the given objet has a title" do
        let(:title) { 'Test Title' }
        context "when the given object has a publisher" do
          let(:publisher) { 'A Journal' }
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication link, publisher, and year" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>, <span class="journal-name">A Journal</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication link and publisher" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>, <span class="journal-name">A Journal</span>}
            end
          end
        end
        context "when the given object does not have a publisher" do
          context "when the given object has a year" do
            let(:year) { 2000 }
            it "returns a label for the given object with a publication link and year" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>, 2000}
            end
          end
          context "when the given object does not have a year" do
            it "returns a label for the given object with a publication link" do
              expect(ad.profile_management_label).to eq %{<span class="publication-title">the pub link</span>}
            end
          end
        end
      end
    end

    context "when the given object is not a journal article" do
      context "when the given object has a title" do
        let(:title) { 'Test Title' }
        before { allow(auth).to receive(:is_journal_article?).and_return false }
        it "returns a label for the given object with the publication title" do
          expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>}
        end
      end
    end

    context "when the given object is not published" do
      context "when the given object has a title" do
        let(:title) { 'Test Title' }
        let(:published) { false }
        it "returns a label without a link for the given object with the publication title" do
          expect(ad.profile_management_label).to eq %{<span class="publication-title">Test Title</span>}
        end
      end
    end
  end

  describe '#open_access_status_icon' do
    context "when the given object is published" do
      context "when the given object does not have an open access URL" do
        context "when the given object does not have a failed ScholarSphere upload" do
          context "when the given object does not have a pending ScholarSphere upload" do
            context "when the given object does not have an open access waiver" do
              it "returns 'question'" do
                expect(ad.open_access_status_icon).to eq 'question'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'lock'" do
                expect(ad.open_access_status_icon).to eq 'lock'
              end
            end
          end
          context "when the given object has a pending ScholarSphere upload" do
            let(:pending) { true }
            context "when the given object does not have an open access waiver" do
              it "returns 'hourglass-half'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'hourglass-half'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end
          end
        end
        context "when the given object has a failed ScholarSphere upload" do
          let(:failed) { true }
          context "when the given object does not have a pending ScholarSphere upload" do
            context "when the given object does not have an open access waiver" do
              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'exclamation-circle'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'exclamation-circle'
              end
            end
          end
          context "when the given object has a pending ScholarSphere upload" do
            let(:pending) { true }
            context "when the given object does not have an open access waiver" do
              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'exclamation-circle'" do
                expect(ad.open_access_status_icon).to eq 'hourglass-half'
              end
            end
          end
        end
      end

      context "when the given object has an open access URL" do
        let(:url) { 'a_url' }
        context "when the given object does not have a failed ScholarSphere upload" do
          context "when the given object does not have a pending ScholarSphere upload" do
            context "when the given object does not have an open access waiver" do
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end
          end
          context "when the given object has a pending ScholarSphere upload" do
            let(:pending) { true }
            context "when the given object does not have an open access waiver" do
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end
          end
        end

        context "when the given object has a failed ScholarSphere upload" do
          let(:failed) { true }
          context "when the given object does not have a pending ScholarSphere upload" do
            context "when the given object does not have an open access waiver" do
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end
          end
          context "when the given object has a pending ScholarSphere upload" do
            let(:pending) { true }
            context "when the given object does not have an open access waiver" do
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end

            context "when the given object has an open access waiver" do
              let(:waived) { true }
              it "returns 'unlock-alt'" do
                expect(ad.open_access_status_icon).to eq 'unlock-alt'
              end
            end
          end
        end
      end
    end
    context "when the given object is not published" do
      let(:published) { false }
      it "returns 'newspaper-o'" do
        expect(ad.open_access_status_icon).to eq 'newspaper-o'
      end
    end
  end
end
