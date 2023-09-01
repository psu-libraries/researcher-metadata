# frozen_string_literal: true

require 'component/component_spec_helper'

describe Healthchecks::DelayedJobErrorCheck do
  describe '#check' do
    context 'when there are no messages' do
      before do
        Delayed::Job.delete_all
      end

      it 'returns no failure' do
        health_check = described_class.new
        health_check.check
        expect(health_check.failure_occurred).to be_nil
      end
    end

    context 'when there are really old messages' do
      before do
        Delayed::Job.create(failed_at: 1.year.ago, handler: 'test')
      end

      it 'returns no failure' do
        health_check = described_class.new
        health_check.check
        expect(health_check.failure_occurred).to be_nil
      end
    end

    context 'when there are messages' do
      before do
        Delayed::Job.create(failed_at: Time.now, handler: 'test')
      end

      it 'returns a failure' do
        health_check = described_class.new
        health_check.check
        expect(health_check.failure_occurred).to be true
      end
    end
  end
end
