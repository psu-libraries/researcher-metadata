# frozen_string_literal: true

require 'component/component_spec_helper'

describe DOIVerificationMergePolicy do
  let(:policy) { described_class.new(merge_target_pub, publications_to_merge) }

  # TODO:  There should be a test somewhere for the case where the merge target doesn't have
  # a DOI and there are multiple publications to merge with the same verified DOI.
  describe '#merge!' do
    context 'when the given merge target has a verified DOI' do
      let(:merge_target_pub) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1103/physrevlett.80.3915') }

      context 'when given a publication to be merged that has a verified DOI that is different than the merge target DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'raises an error' do
            expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'raises an error' do
            expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end
      end

      context 'when given a publication to be merged that has a verified DOI that is the same as the merge target DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1103/physrevlett.80.3915') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has a DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has a verified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has a nil DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end
    end

    context 'when the given merge target has an unverified DOI' do
      let(:merge_target_pub) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1103/physrevlett.80.3915') }

      context 'when given a publication to be merged that has a verified DOI that is different than the merge target DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a verified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end          
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a nil DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end
    end

    context 'when the given merge target has a DOI with unknown verification' do
      let(:merge_target_pub) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1103/physrevlett.80.3915') }

      context 'when given a publication to be merged that has a verified DOI that is different than the merge target DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end

      context 'when given a publication to be merged that has a DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end

      context 'when given a publication to be merged that has a verified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end          
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end

      context 'when given a publication to be merged that has a nil DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the original DOI of the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the original DOI of the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1103/physrevlett.80.3915'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end
    end

    context 'when the given merge target has a verified nil DOI' do
      let(:merge_target_pub) { create(:publication, doi_verified: true, doi: nil) }

      context 'when given a publication to be merged that has a verified DOI that is different than the merge target DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the unverified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the unverified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          # TODO:  We need additional contexts here for groups of publications with and
          # without Pure imports.
          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end

      context 'when given a publication to be merged that has a verified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has a nil DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end
    end

    context 'when the given merge target has an unverified nil DOI' do
      let(:merge_target_pub) { create(:publication, doi_verified: false, doi: nil) }

      context 'when given a publication to be merged that has a verified DOI that is different than the merge target DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the unverified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the unverified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end

      context 'when given a publication to be merged that has a verified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end          
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the unverified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the unverified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a nil DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the unverified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the unverified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end
    end

    context 'when the given merge target has a nil DOI with unknown verification' do
      let(:merge_target_pub) { create(:publication, doi_verified: nil, doi: nil) }

      context 'when given a publication to be merged that has a verified DOI that is different than the merge target DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the verified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'raises an error' do
              expect { policy.merge! }.to raise_error DOIVerificationMergePolicy::UnmergablePublications
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the unverified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the unverified DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1001/archderm.139.10.1363-g') }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the DOI from the merged publication on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            xit 'it saves the DOI from the publication with a Pure import'
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1001/archderm.139.10.1363-g'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end

      context 'when given a publication to be merged that has a verified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: true, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the verified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq true
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end          
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end
      end

      context 'when given a publication to be merged that has an unverified nil DOI' do
        let(:pub2) { create(:publication, doi_verified: false, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'saves the unverified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'saves the unverified nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq false
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end
      end

      context 'when given a publication to be merged that has a nil DOI with unknown verification' do
        let(:pub2) { create(:publication, doi_verified: nil, doi: nil) }

        context 'when the set of given publications to be merged includes the merge target' do
          let(:publications_to_merge) { [merge_target_pub, pub2] }

          it 'keeps the nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when the set of given publications to be merged does not include the merge target' do
          let(:publications_to_merge) { [pub2] }

          it 'keeps the nil DOI on the merge target' do
            policy.merge!
            reloaded_target = merge_target_pub.reload
            expect(reloaded_target.doi).to be_nil
            expect(reloaded_target.doi_verified).to eq nil
          end
        end

        context 'when given a second publication to be merged that has a verified DOI that is different than the merge target DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: 'https://doi.org/10.1126/science.ads5951') }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the DOI from the second merged publication on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to eq 'https://doi.org/10.1126/science.ads5951'
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end

        context 'when given a second publication to be merged that has a verified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: true, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the verified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq true
            end
          end
        end

        context 'when given a second publication to be merged that has an unverified nil DOI' do
          let(:pub3) { create(:publication, doi_verified: false, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'saves the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'saves the unverified nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq false
            end
          end
        end

        context 'when given a second publication to be merged that has a nil DOI with unknown verification' do
          let(:pub3) { create(:publication, doi_verified: nil, doi: nil) }

          context 'when the set of given publications to be merged includes the merge target' do
            let(:publications_to_merge) { [merge_target_pub, pub2, pub3] }

            it 'keeps the nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq nil
            end
          end

          context 'when the set of given publications to be merged does not include the merge target' do
            let(:publications_to_merge) { [pub2, pub3] }

            it 'keeps the nil DOI on the merge target' do
              policy.merge!
              reloaded_target = merge_target_pub.reload
              expect(reloaded_target.doi).to be_nil
              expect(reloaded_target.doi_verified).to eq nil
            end
          end
        end
      end
    end
  end
end
