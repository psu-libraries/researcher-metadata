# frozen_string_literal: true

require 'component/component_spec_helper'

describe ApplicationHelper, type: :helper do
  describe '#new_session_path' do
    it "returns the application's root path" do
      expect(helper.new_session_path(nil)).to eq root_path
    end
  end
end
