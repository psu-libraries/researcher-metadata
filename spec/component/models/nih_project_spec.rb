# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHProject do
  let(:project) { described_class.new(project_data) }
  let(:project_data) {
    {
      'project_title' => 'Test Title',
      'budget_start' => start_date,
      'budget_end' => end_date,
      'abstract_text' => 'test abstract',
      'award_amount' => 50000,
      'project_num' => 'abc12345',
      'agency_code' => agency,
      'principal_investigators' => principal_investigators,
      'core_project_num' => '12345'
    }
  }
  let(:pi_data_1) { double 'PI data 1' }
  let(:pi_data_2) { double 'PI data 2' }
  let(:principal_investigators) { [pi_data_1, pi_data_2] }
  let(:pi_1) { instance_double NIHProjectInvestigator }
  let(:pi_2) { instance_double NIHProjectInvestigator }
  let(:start_date) { '2026-03-01T00:00:00' }
  let(:end_date) { '2027-02-28T00:00:00' }
  let(:agency) { 'FDA' }

  before do
    allow(NIHProjectInvestigator).to receive(:new).with(pi_data_1).and_return pi_1
    allow(NIHProjectInvestigator).to receive(:new).with(pi_data_2).and_return pi_2
  end

  describe '#title' do
    it 'returns the project title from the given data' do
      expect(project.title).to eq 'Test Title'
    end
  end

  describe '#start_date' do
    context 'when the given data contains a valid start date string' do
      it 'returns the project start date from the given data' do
        expect(project.start_date).to eq Date.new(2026, 3, 1)
      end
    end

    context 'when the given data contains an invalid start date string' do
      let(:start_date) { 'bad' }

      it 'returns nil' do
        expect(project.start_date).to be_nil
      end
    end
  end

  describe '#end_date' do
    context 'when the given data contains a valid end date string' do
      it 'returns the project end date from the given data' do
        expect(project.end_date).to eq Date.new(2027, 2, 28)
      end
    end

    context 'when the given data contains an invalid end date string' do
      let(:end_date) { 'bad' }

      it 'returns nil' do
        expect(project.end_date).to be_nil
      end
    end
  end

  describe '#abstract' do
    it 'returns the project abstract from the given data' do
      expect(project.abstract).to eq 'test abstract'
    end
  end

  describe '#amount_in_dollars' do
    it 'returns the grant amount in dollars from the given data' do
      expect(project.amount_in_dollars).to eq 50000
    end
  end

  describe '#identifier' do
    it 'returns the project identifier from the given data' do
      expect(project.identifier).to eq 'abc12345'
    end
  end

  describe '#agency_name' do
    context 'when the given data contains an agency code' do
      it 'returns the agency code from the given data' do
        expect(project.agency_name).to eq 'FDA'
      end
    end

    context 'when the given data does not contain an agency code' do
      let(:agency) { nil }

      it "returns 'NIH'" do
        expect(project.agency_name).to eq 'NIH'
      end
    end
  end

  describe '#principal_investigators' do
    context 'when the given data has a list of principal investigators' do
      it 'returns an NIHProjectInvestigator for each principal investigator in the given data' do
        expect(project.principal_investigators).to eq [pi_1, pi_2]
      end
    end

    context 'when the given data does not have a list of principal investigators' do
      let(:principal_investigators) { nil }

      it 'returns an empty array' do
        expect(project.principal_investigators).to eq []
      end
    end
  end

  describe '#publications' do
    let(:api_client) { instance_double NIHAPIClient }
    let(:pub_data_1) { double 'publication data 1' }
    let(:pub_data_2) { double 'publication data 2' }
    let(:pub_1) { instance_double NIHProjectPublication }
    let(:pub_2) { instance_double NIHProjectPublication }

    before do
      allow(NIHAPIClient).to receive(:new).and_return api_client
      allow(api_client).to receive(:publications_by_project).with('12345').and_return [pub_data_1, pub_data_2]
      allow(NIHProjectPublication).to receive(:new).with(pub_data_1).and_return pub_1
      allow(NIHProjectPublication).to receive(:new).with(pub_data_2).and_return pub_2
    end

    it 'returns an NIHProjectPublication for each publication in the PubMed database associated with the core project number in the given data' do
      expect(project.publications).to eq [pub_1, pub_2]
    end
  end
end
