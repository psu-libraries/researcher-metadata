require 'unit/unit_spec_helper'
require 'active_support'
require 'active_support/core_ext'
require_relative '../../../app/importers/activity_insight_importer'

describe ActivityInsightEducationHistoryItem do
  let(:parsed_item) { double 'parsed item xml' }
  let(:item) { ActivityInsightEducationHistoryItem.new(parsed_item) }

  describe '#activity_insight_id' do
    let(:id_attr) { double 'id attribute', value: '8'}
    before { allow(parsed_item).to receive(:attribute).with('id').and_return(id_attr) }

    it "returns the id attribute from the given element" do
      expect(item.activity_insight_id).to eq '8'
    end
  end

  describe '#degree' do
    before { allow(parsed_item).to receive(:css).with('DEG').and_return(degree_element) }

    context "when the Degree element in the given data is empty" do
      let(:degree_element) { double 'degree element', text: '' }
      it "returns nil" do
        expect(item.degree).to be_nil
      end
    end

    context "when the Degree element in the given data contains text" do
      let(:degree_element) { double 'degree element', text: "\n     Degree  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.degree).to eq 'Degree'
      end
    end
  end

  describe '#explanation_of_other_degree' do
    before { allow(parsed_item).to receive(:css).with('DEGOTHER').and_return(degree_other_element) }

    context "when the Degree Other element in the given data is empty" do
      let(:degree_other_element) { double 'degree other element', text: '' }
      it "returns nil" do
        expect(item.explanation_of_other_degree).to be_nil
      end
    end

    context "when the Degree Other element in the given data contains text" do
      let(:degree_other_element) { double 'degree other element', text: "\n     Degree Explanation  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.explanation_of_other_degree).to eq 'Degree Explanation'
      end
    end
  end

  describe '#is_highest_degree_earned' do
    before { allow(parsed_item).to receive(:css).with('HIGHEST').and_return(highest_element) }

    context "when the Highest element in the given data is empty" do
      let(:highest_element) { double 'highest element', text: '' }
      it "returns nil" do
        expect(item.is_highest_degree_earned).to be_nil
      end
    end

    context "when the Highest element in the given data contains text" do
      let(:highest_element) { double 'highest element', text: "\n     Yes  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.is_highest_degree_earned).to eq 'Yes'
      end
    end
  end

  describe '#institution' do
    before { allow(parsed_item).to receive(:css).with('SCHOOL').and_return(school_element) }

    context "when the School element in the given data is empty" do
      let(:school_element) { double 'school element', text: '' }
      it "returns nil" do
        expect(item.institution).to be_nil
      end
    end

    context "when the School element in the given data contains text" do
      let(:school_element) { double 'school element', text: "\n     Institution  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.institution).to eq 'Institution'
      end
    end
  end

  describe '#institution' do
    before { allow(parsed_item).to receive(:css).with('SCHOOL').and_return(school_element) }

    context "when the School element in the given data is empty" do
      let(:school_element) { double 'school element', text: '' }
      it "returns nil" do
        expect(item.institution).to be_nil
      end
    end

    context "when the School element in the given data contains text" do
      let(:school_element) { double 'school element', text: "\n     Institution  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.institution).to eq 'Institution'
      end
    end
  end

  describe '#school' do
    before { allow(parsed_item).to receive(:css).with('COLLEGE').and_return(college_element) }

    context "when the College element in the given data is empty" do
      let(:college_element) { double 'college element', text: '' }
      it "returns nil" do
        expect(item.school).to be_nil
      end
    end

    context "when the College element in the given data contains text" do
      let(:college_element) { double 'college element', text: "\n     School  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.school).to eq 'School'
      end
    end
  end

  describe '#location_of_institution' do
    before { allow(parsed_item).to receive(:css).with('LOCATION').and_return(location_element) }

    context "when the Location element in the given data is empty" do
      let(:location_element) { double 'location element', text: '' }
      it "returns nil" do
        expect(item.location_of_institution).to be_nil
      end
    end

    context "when the Location element in the given data contains text" do
      let(:location_element) { double 'location element', text: "\n     Location  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.location_of_institution).to eq 'Location'
      end
    end
  end

  describe '#emphasis_or_major' do
    before { allow(parsed_item).to receive(:css).with('MAJOR').and_return(major_element) }

    context "when the Major element in the given data is empty" do
      let(:major_element) { double 'major element', text: '' }
      it "returns nil" do
        expect(item.emphasis_or_major).to be_nil
      end
    end

    context "when the Major element in the given data contains text" do
      let(:major_element) { double 'major element', text: "\n     Major  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.emphasis_or_major).to eq 'Major'
      end
    end
  end

  describe '#supporting_areas_of_emphasis' do
    before { allow(parsed_item).to receive(:css).with('SUPPAREA').and_return(supporting_element) }

    context "when the Supporting Area element in the given data is empty" do
      let(:supporting_element) { double 'supporting element', text: '' }
      it "returns nil" do
        expect(item.supporting_areas_of_emphasis).to be_nil
      end
    end

    context "when the Supporting Area element in the given data contains text" do
      let(:supporting_element) { double 'supporting element', text: "\n     Supporting Area  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.supporting_areas_of_emphasis).to eq 'Supporting Area'
      end
    end
  end

  describe '#dissertation_or_thesis_title' do
    before { allow(parsed_item).to receive(:css).with('DISSTITLE').and_return(dissertation_element) }

    context "when the Dissertation Title element in the given data is empty" do
      let(:dissertation_element) { double 'dissertation element', text: '' }
      it "returns nil" do
        expect(item.dissertation_or_thesis_title).to be_nil
      end
    end

    context "when the Dissertation Title element in the given data contains text" do
      let(:dissertation_element) { double 'dissertation element', text: "\n     Dissertation  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.dissertation_or_thesis_title).to eq 'Dissertation'
      end
    end
  end

  describe '#honor_or_distinction' do
    before { allow(parsed_item).to receive(:css).with('DISTINCTION').and_return(distinction_element) }

    context "when the Distinction element in the given data is empty" do
      let(:distinction_element) { double 'distinction element', text: '' }
      it "returns nil" do
        expect(item.honor_or_distinction).to be_nil
      end
    end

    context "when the Distinction element in the given data contains text" do
      let(:distinction_element) { double 'distinction element', text: "\n     Distinction  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.honor_or_distinction).to eq 'Distinction'
      end
    end
  end

  describe '#description' do
    before { allow(parsed_item).to receive(:css).with('DESC').and_return(description_element) }

    context "when the Description element in the given data is empty" do
      let(:description_element) { double 'description element', text: '' }
      it "returns nil" do
        expect(item.description).to be_nil
      end
    end

    context "when the Description element in the given data contains text" do
      let(:description_element) { double 'description element', text: "\n     Description  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.description).to eq 'Description'
      end
    end
  end

  describe '#comments' do
    before { allow(parsed_item).to receive(:css).with('COMMENT').and_return(comments_element) }

    context "when the Comments element in the given data is empty" do
      let(:comments_element) { double 'comments element', text: '' }
      it "returns nil" do
        expect(item.comments).to be_nil
      end
    end

    context "when the Comments element in the given data contains text" do
      let(:comments_element) { double 'comments element', text: "\n     Comments  \n   " }

      it "returns the text with surrounding whitespace removed" do
        expect(item.comments).to eq 'Comments'
      end
    end
  end
end
