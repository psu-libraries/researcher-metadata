require 'component/component_spec_helper'

describe ActivityInsightContractImporter do
  let(:importer) { ActivityInsightContractImporter.new(filename: filename) }

  describe '#call' do
    context "when given a well-formed .csv file of valid contract data from Activity Insight" do
      let(:filename) { Rails.root.join('spec', 'fixtures', 'ai_contracts.csv') }

      context "when no contract records exist in the database" do
        it "creates a new import record for every contract in the .csv that has an ospkey and was awarded" do
          expect { importer.call }.to change { ContractImport.count }.by 3
        end

        it "creates a new contract record for every contract in the .csv that has an ospkey and was awarded" do
          expect { importer.call }.to change { Contract.count }.by 3

          c1 = ContractImport.find_by(activity_insight_id: '163281506304').contract
          c2 = ContractImport.find_by(activity_insight_id: '84691750912').contract
          c3 = ContractImport.find_by(activity_insight_id: '84691748864').contract

          expect(c1.title).to eq 'Test Contract Three'
          expect(c1.contract_type).to eq 'Grant'
          expect(c1.sponsor).to eq 'Test Org Three'
          expect(c1.status).to eq 'Awarded'
          expect(c1.amount).to eq 700
          expect(c1.ospkey).to eq 156436
          expect(c1.award_start_on).to eq Date.new(2017, 10, 30)
          expect(c1.award_end_on).to eq Date.new(2017, 10, 30)
          expect(c1.visible).to eq false

          expect(c2.title).to eq 'Test Contract Four'
          expect(c2.contract_type).to eq 'Grant'
          expect(c2.sponsor).to eq 'Test Org Four'
          expect(c2.status).to eq 'Awarded'
          expect(c2.amount).to eq 365000
          expect(c2.ospkey).to eq 160956
          expect(c2.award_start_on).to eq Date.new(2012, 12, 6)
          expect(c2.award_end_on).to eq Date.new(2012, 12, 6)
          expect(c2.visible).to eq false

          expect(c3.title).to eq 'Test Contract Five'
          expect(c3.contract_type).to eq 'Contract'
          expect(c3.sponsor).to eq 'Test Org Five'
          expect(c3.status).to eq 'Awarded'
          expect(c3.amount).to eq 42390
          expect(c3.ospkey).to eq 143481
          expect(c3.award_start_on).to eq nil
          expect(c3.award_end_on).to eq nil
          expect(c3.visible).to eq false
        end
      end
    end
  end
end
