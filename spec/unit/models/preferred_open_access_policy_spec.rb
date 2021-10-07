require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/models/preferred_open_access_policy'

describe PreferredOpenAccessPolicy do
  let(:policy) { PreferredOpenAccessPolicy.new(pub) }
  let(:pub) { double 'publication',
                     scholarsphere_open_access_url: ssoau,
                     open_access_url: oau,
                     user_submitted_open_access_url: usoau }

  let(:oau) { nil }
  let(:ssoau) { nil }
  let(:usoau) { nil }

  describe '#url' do
    context 'when the publication has an open access URL' do
      let(:oau) { 'A URL' }

      context 'when the publication has a user-submitted open access URL' do
        let(:usoau) { 'User URL' }

        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns the open access URL' do
            expect(policy.url).to eq 'A URL'
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns the open access URL' do
            expect(policy.url).to eq 'A URL'
          end
        end
      end

      context "when the publication's user-submitted open access URL is blank" do
        let(:usoau) { '' }

        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns the open access URL' do
            expect(policy.url).to eq 'A URL'
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns the open access URL' do
            expect(policy.url).to eq 'A URL'
          end
        end
      end

      context 'when the publication does not have a user-submitted open access URL' do
        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns the open access URL' do
            expect(policy.url).to eq 'A URL'
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns the open access URL' do
            expect(policy.url).to eq 'A URL'
          end
        end
      end
    end

    context "when the publication's open access URL is blank" do
      let(:oau) { '' }

      context 'when the publication has a user-submitted open access URL' do
        let(:usoau) { 'User URL' }

        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns the user-submitted open access URL' do
            expect(policy.url).to eq 'User URL'
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns the user-submitted open access URL' do
            expect(policy.url).to eq 'User URL'
          end
        end
      end

      context "when the publication's user-submitted open access URL is blank" do
        let(:usoau) { '' }

        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end
      end

      context 'when the publication does not have a user-submitted open access URL' do
        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end
      end
    end

    context 'when the publication does not have an open access URL' do
      context 'when the publication has a user-submitted open access URL' do
        let(:usoau) { 'User URL' }

        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns the user-submitted open access URL' do
            expect(policy.url).to eq 'User URL'
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns the user-submitted open access URL' do
            expect(policy.url).to eq 'User URL'
          end
        end
      end

      context "when the publication's user-submitted open access URL is blank" do
        let(:usoau) { '' }

        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end
      end

      context 'when the publication does not have a user-submitted open access URL' do
        context 'when the publication has a Scholarsphere open access URL' do
          let(:ssoau) { 'Scholarsphere URL' }

          it 'returns the Scholarsphere open access URL' do
            expect(policy.url).to eq 'Scholarsphere URL'
          end
        end

        context "when the publication's Scholarsphere open access URL is blank" do
          let(:ssoau) { '' }

          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end

        context 'when the publication does not have a Scholarsphere open access URL' do
          it 'returns nil' do
            expect(policy.url).to be_nil
          end
        end
      end
    end
  end
end
