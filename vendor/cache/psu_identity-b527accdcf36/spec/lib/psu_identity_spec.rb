# frozen_string_literal: true

RSpec.describe PsuIdentity do
  it 'has a version number' do
    expect(PsuIdentity::VERSION).not_to be nil
  end

  specify do
    expect(PsuIdentity::Error.ancestors).to include(StandardError)
  end
end
