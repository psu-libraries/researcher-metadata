# frozen_string_literal: true

require 'component/component_spec_helper'

describe API::V1::GrantSerializer do
  let(:grant) {
    instance_double(
      Grant,
      id: 1,
      title: 'a grant',
      agency_name: 'an agency',
      abstract: 'the abstract',
      amount_in_dollars: 1000000,
      start_date: start_date,
      end_date: end_date,
      identifier: 'abc123'
    )
  }

  let(:start_date) { nil }
  let(:end_date) { nil }

  describe 'data attributes' do
    subject { serialized_data_attributes(grant) }

    it { is_expected.to include(title: 'a grant') }
    it { is_expected.to include(agency_name: 'an agency') }
    it { is_expected.to include(abstract: 'the abstract') }
    it { is_expected.to include(amount_in_dollars: 1000000) }
    it { is_expected.to include(identifier: 'abc123') }

    context 'when the grant has a start date' do
      let(:start_date) { Date.new(2017, 9, 1) }

      it { is_expected.to include(start_date: '2017-09-01') }
    end

    context 'when the grant does not have a start date' do
      it { is_expected.to include(start_date: nil) }
    end

    context 'when the grant has an end date' do
      let(:end_date) { Date.new(2018, 8, 1) }

      it { is_expected.to include(end_date: '2018-08-01') }
    end

    context 'when the grant does not have an end date' do
      it { is_expected.to include(end_date: nil) }
    end
  end
end
