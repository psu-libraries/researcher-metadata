# frozen_string_literal: true

require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_importer_error_log'

describe ImporterErrorLog::OpenAccessButtonImporterErrorLog, type: :model do
  it_behaves_like 'an importer error log'
end
