require 'unit/unit_spec_helper'
require_relative '../../../app/models/null_time'
require_relative '../../../app/models/null_comparable_time'

describe NullTime do
  let(:nct) { NullComparableTime.new(1990, 1, 1, 0, 0, 0) }

  describe '#<=>' do
    context "when given a subsequent time" do
      it "returns -1" do
        expect(nct.<=>(Time.new(2000, 1, 1, 0, 0, 0))).to eq -1
      end
    end

    context "when given a null time" do
      it "returns 1" do
        expect(nct.<=>(NullTime.new)).to eq 1
      end
    end
  end
end
