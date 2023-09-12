# frozen_string_literal: true

require 'component/component_spec_helper'

describe OABPermissionsSet do
  let(:ps) { described_class.new(permissions) }
  let(:permissions) { [] }

  describe '#can_deposit_accepted_version?' do
    context 'when the set has no permissions' do
      it 'returns false' do
        expect(ps.can_deposit_accepted_version?).to be false
      end
    end

    context 'when the set has a permission' do
      let(:permissions) { [permission] }
      let(:permission) { instance_double OABPermission }

      context 'when that permission is for the accepted version' do
        before { allow(permission).to receive(:version).and_return 'acceptedVersion' }

        context 'when that permission allows deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return true }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_accepted_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns true' do
              expect(ps.can_deposit_accepted_version?).to be true
            end
          end
        end

        context 'when that permission does not allow deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return false }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_accepted_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns false' do
              expect(ps.can_deposit_accepted_version?).to be false
            end
          end
        end
      end

      context 'when that permission is not for the accepted version' do
        before { allow(permission).to receive(:version).and_return 'publishedVersion' }

        context 'when that permission allows deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return true }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_accepted_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns false' do
              expect(ps.can_deposit_accepted_version?).to be false
            end
          end
        end

        context 'when that permission does not allow deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return false }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_accepted_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns false' do
              expect(ps.can_deposit_accepted_version?).to be false
            end
          end
        end
      end
    end
  end

  describe '#can_deposit_published_version?' do
    context 'when the set has no permissions' do
      it 'returns false' do
        expect(ps.can_deposit_published_version?).to be false
      end
    end

    context 'when the set has a permission' do
      let(:permissions) { [permission] }
      let(:permission) { instance_double OABPermission }

      context 'when that permission is for the published version' do
        before { allow(permission).to receive(:version).and_return 'publishedVersion' }

        context 'when that permission allows deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return true }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_published_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns true' do
              expect(ps.can_deposit_published_version?).to be true
            end
          end
        end

        context 'when that permission does not allow deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return false }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_published_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns false' do
              expect(ps.can_deposit_published_version?).to be false
            end
          end
        end
      end

      context 'when that permission is not for the published version' do
        before { allow(permission).to receive(:version).and_return 'acceptedVersion' }

        context 'when that permission allows deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return true }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_published_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns false' do
              expect(ps.can_deposit_published_version?).to be false
            end
          end
        end

        context 'when that permission does not allow deposit in an institutional repository' do
          before { allow(permission).to receive(:can_archive_in_institutional_repository?).and_return false }

          context 'when that permission has requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return true }

            it 'returns false' do
              expect(ps.can_deposit_published_version?).to be false
            end
          end

          context 'when that permission does not have requirements' do
            before { allow(permission).to receive(:has_requirements?).and_return false }

            it 'returns false' do
              expect(ps.can_deposit_published_version?).to be false
            end
          end
        end
      end
    end
  end
end
