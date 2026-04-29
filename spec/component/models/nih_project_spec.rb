# frozen_string_literal: true

require 'component/component_spec_helper'

describe NIHProject do
  let(:project) { described_class.new(project_data) }
  let(:project_data) {
    {
      'project_title' => 'Test Title',
      'budget_start' => '2026-03-01T00:00:00',
      'budget_end' => '2027-02-28T00:00:00',
      'abstract_text' => 'test abstract',
      'award_amount' => 50000,
      'project_num' => 'abc12345',
      'agency_code' => 'NIH',
      'principal_investigators' => [pi_data_1, pi_data_2],
      'core_project_num' => '12345'
    }
  }
  let(:pi_data_1) { double 'PI data 1' }
  let(:pi_data_2) { double 'PI data 2' }
  let(:pi_1) { instance_double NIHProjectInvestigator }
  let(:pi_2) { instance_double NIHProjectInvestigator }

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
    it 'returns the project start date from the given data' do
      expect(project.start_date).to eq Date.new(2026, 3, 1)
    end
  end

  describe '#end_date' do
    it 'returns the project end date from the given data' do
      expect(project.end_date).to eq Date.new(2027, 2, 28)
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
    it 'returns the agency code from the given data' do
      expect(project.agency_name).to eq 'NIH'
    end
  end

  describe '#principal_investigators' do
    it 'returns an NIHProjectInvestigator for each principal investigator in the given data' do
      expect(project.principal_investigators).to eq [pi_1, pi_2]
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
