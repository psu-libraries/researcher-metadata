require 'component/component_spec_helper'
require 'component/models/shared_examples_for_an_importer_error_log'

describe ImporterErrorLog::ActivityInsightImporterErrorLog, type: :model do
  it_behaves_like 'an importer error log'
end
