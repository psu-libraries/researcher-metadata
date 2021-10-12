# frozen_string_literal: true

FactoryBot.define do
  factory :importer_error_log do
    importer_type { 'FactoryBotImporter' }
    error_type { 'RuntimeError' }
    error_message { 'Why did it break?' }
    metadata { { 'key' => 'val' } }
    occurred_at { 1.minute.ago }
    stacktrace { '["trace1", "trace2"]' }
  end
end
