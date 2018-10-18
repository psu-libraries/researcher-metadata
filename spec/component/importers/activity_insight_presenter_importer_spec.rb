require 'component/component_spec_helper'

describe ActivityInsightPresenterImporter do
  let(:importer) { ActivityInsightPresenterImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid presenter data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_presenters.csv') }

      context "when no presentation contribution records exist in the database" do
        context "when a user exists for every Penn State contribution in the .csv" do
          let!(:u1) { create :user, activity_insight_identifier: '1000000' }
          let!(:u2) { create :user, activity_insight_identifier: '1000001' }

          context "when a presentation exists for every Penn State authorship in the .csv" do
            let!(:p1) {  create :presentation, activity_insight_identifier: '113168144384' }
            let!(:p2) {  create :presentation, activity_insight_identifier: '107659857920' }
            let!(:p3) {  create :presentation, activity_insight_identifier: '169406947328' }

            it "creates a new record for every Penn State contribution in the .csv" do
              expect { importer.call }.to change { PresentationContribution.count }.by 3

              pc1 = PresentationContribution.find_by(activity_insight_identifier: '113168144385')
              pc2 = PresentationContribution.find_by(activity_insight_identifier: '107659857921')
              pc3 = PresentationContribution.find_by(activity_insight_identifier: '169406947329')

              expect(pc1.user).to eq u1
              expect(pc1.presentation).to eq p1
              expect(pc1.position).to eq 1
              expect(pc1.role).to eq 'Some Other Role'

              expect(pc2.user).to eq u1
              expect(pc2.presentation).to eq p2
              expect(pc2.position).to eq 1
              expect(pc2.role).to eq 'Author Only'

              expect(pc3.user).to eq u2
              expect(pc3.presentation).to eq p3
              expect(pc3.position).to eq 2
              expect(pc3.role).to eq 'Presenter and Author'
            end
          end

          context "when no presentation exists for a Penn State contribution in the .csv" do
            let!(:p1) {  create :presentation, activity_insight_identifier: '107659857920' }
            let!(:p2) {  create :presentation, activity_insight_identifier: '169406947328' }

            it "creates a new record for every Penn State contribution in the .csv with a corresponding presentation" do
              expect { importer.call }.to change { PresentationContribution.count }.by 2

              pc1 = PresentationContribution.find_by(activity_insight_identifier: '107659857921')
              pc2 = PresentationContribution.find_by(activity_insight_identifier: '169406947329')

              expect(pc1.user).to eq u1
              expect(pc1.presentation).to eq p1
              expect(pc1.position).to eq 1
              expect(pc1.role).to eq 'Author Only'

              expect(pc2.user).to eq u2
              expect(pc2.presentation).to eq p2
              expect(pc2.position).to eq 2
              expect(pc2.role).to eq 'Presenter and Author'
            end
          end
        end

        context "when no user exists for a Penn State contribution in the .csv" do
          let!(:u1) { create :user, activity_insight_identifier: '1000000' }

          context "when a presentation exists for every Penn State contribution in the .csv" do
            let!(:p1) {  create :presentation, activity_insight_identifier: '113168144384' }
            let!(:p2) {  create :presentation, activity_insight_identifier: '107659857920' }
            let!(:p3) {  create :presentation, activity_insight_identifier: '169406947328' }

            it "creates a new record for every Penn State contribution in the .csv with a corresponding user" do
              expect { importer.call }.to change { PresentationContribution.count }.by 2

              pc1 = PresentationContribution.find_by(activity_insight_identifier: '113168144385')
              pc2 = PresentationContribution.find_by(activity_insight_identifier: '107659857921')

              expect(pc1.user).to eq u1
              expect(pc1.presentation).to eq p1
              expect(pc1.position).to eq 1
              expect(pc1.role).to eq 'Some Other Role'

              expect(pc2.user).to eq u1
              expect(pc2.presentation).to eq p2
              expect(pc2.position).to eq 1
              expect(pc2.role).to eq 'Author Only'
            end
          end

          context "when no presentation exists for a Penn State contribution in the .csv" do
            let!(:p1) {  create :presentation, activity_insight_identifier: '107659857920' }
            let!(:p2) {  create :presentation, activity_insight_identifier: '169406947328' }

            it "creates a new record for every Penn State contribution in the .csv with a corresponding presentation" do
              expect { importer.call }.to change { PresentationContribution.count }.by 1

              pc1 = PresentationContribution.find_by(activity_insight_identifier: '107659857921')

              expect(pc1.user).to eq u1
              expect(pc1.presentation).to eq p1
              expect(pc1.position).to eq 1
              expect(pc1.role).to eq 'Author Only'
            end
          end
        end
      end

      context "when a contribution record already exists for a Penn State presenter in the .csv" do
        before { create :presentation_contribution,
                        activity_insight_identifier: '113168144385',
                        user: u2,
                        presentation: p3,
                        position: 4,
                        role: 'Existing Role' }

        context "when a user exists for every Penn State contribution in the .csv" do
          let!(:u1) { create :user, activity_insight_identifier: '1000000' }
          let!(:u2) { create :user, activity_insight_identifier: '1000001' }

          context "when a presentation exists for every Penn State authorship in the .csv" do
            let!(:p1) {  create :presentation, activity_insight_identifier: '113168144384' }
            let!(:p2) {  create :presentation, activity_insight_identifier: '107659857920' }
            let!(:p3) {  create :presentation, activity_insight_identifier: '169406947328' }

            it "creates a new record for every Penn State contribution in the .csv and updates the existing records" do
              expect { importer.call }.to change { PresentationContribution.count }.by 2

              pc1 = PresentationContribution.find_by(activity_insight_identifier: '113168144385')
              pc2 = PresentationContribution.find_by(activity_insight_identifier: '107659857921')
              pc3 = PresentationContribution.find_by(activity_insight_identifier: '169406947329')

              expect(pc1.user).to eq u1
              expect(pc1.presentation).to eq p1
              expect(pc1.position).to eq 1
              expect(pc1.role).to eq 'Some Other Role'

              expect(pc2.user).to eq u1
              expect(pc2.presentation).to eq p2
              expect(pc2.position).to eq 1
              expect(pc2.role).to eq 'Author Only'

              expect(pc3.user).to eq u2
              expect(pc3.presentation).to eq p3
              expect(pc3.position).to eq 2
              expect(pc3.role).to eq 'Presenter and Author'
            end
          end
        end
      end
    end
  end
end
