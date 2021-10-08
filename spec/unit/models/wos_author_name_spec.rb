# frozen_string_literal: true

require 'unit/unit_spec_helper'
require_relative '../../../app/models/wos_author_name'

describe WOSAuthorName do
  let(:name) { double 'name' }
  let(:wos_name) { described_class.new(name) }

  describe '#first_name' do
    context 'given only one name' do
      let(:name) { 'Author' }

      it 'returns nil' do
        expect(wos_name.first_name).to eq nil
      end
    end

    context 'given a full name with a first initial and no middle name' do
      let(:name) { 'Author, S.' }

      it 'returns nil' do
        expect(wos_name.first_name).to eq nil
      end
    end

    context 'given a full name with a first initial and a middle initial' do
      let(:name) { 'Author, S. A.' }

      it 'returns nil' do
        expect(wos_name.first_name).to eq nil
      end
    end

    context 'given a full name with a first name and no middle initial' do
      let(:name) { 'Author, Sally' }

      it 'returns the first name' do
        expect(wos_name.first_name).to eq 'Sally'
      end
    end

    context 'given a full name with a first name and a middle initial' do
      let(:name) { 'Author, Sally A.' }

      it 'returns the first name' do
        expect(wos_name.first_name).to eq 'Sally'
      end
    end

    context 'given a full name with a first name and a middle name' do
      let(:name) { 'Author, Sally Anne' }

      it 'returns the first name' do
        expect(wos_name.first_name).to eq 'Sally'
      end
    end

    context 'given a full name with a first name and two middle initials' do
      let(:name) { 'Author, Sally A. B.' }

      it 'returns the first name' do
        expect(wos_name.first_name).to eq 'Sally'
      end
    end

    context 'given a full name with a first name, middle initial, and suffix' do
      let(:name) { 'Author, Sally A., Jr.' }

      it 'returns the first name' do
        expect(wos_name.first_name).to eq 'Sally'
      end
    end
  end

  describe '#middle_name' do
    context 'given only one name' do
      let(:name) { 'Author' }

      it 'returns nil' do
        expect(wos_name.middle_name).to eq nil
      end
    end

    context 'given a full name with a first initial and no middle name' do
      let(:name) { 'Author, S.' }

      it 'returns nil' do
        expect(wos_name.middle_name).to eq nil
      end
    end

    context 'given a full name with a first initial and a middle initial' do
      let(:name) { 'Author, S. A.' }

      it 'returns nil' do
        expect(wos_name.middle_name).to eq nil
      end
    end

    context 'given a full name with a first name and no middle initial' do
      let(:name) { 'Author, Sally' }

      it 'returns nil' do
        expect(wos_name.middle_name).to eq nil
      end
    end

    context 'given a full name with a first name and a middle initial' do
      let(:name) { 'Author, Sally A.' }

      it 'returns nil' do
        expect(wos_name.middle_name).to eq nil
      end
    end

    context 'given a full name with a first name and a middle name' do
      let(:name) { 'Author, Sally Anne' }

      it 'returns the middle name' do
        expect(wos_name.middle_name).to eq 'Anne'
      end
    end

    context 'given a full name with a first name and two middle initials' do
      let(:name) { 'Author, Sally A. B.' }

      it 'returns nil' do
        expect(wos_name.middle_name).to eq nil
      end
    end

    context 'given a full name with a first name, middle initial, and suffix' do
      let(:name) { 'Author, Sally A., Jr.' }

      it 'returns nil' do
        expect(wos_name.middle_name).to eq nil
      end
    end
  end

  describe '#last_name' do
    context 'given only one name' do
      let(:name) { 'Author' }

      it 'returns the name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end

    context 'given a full name with a first initial and no middle name' do
      let(:name) { 'Author, S.' }

      it 'returns the last name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end

    context 'given a full name with a first initial and a middle initial' do
      let(:name) { 'Author, S. A.' }

      it 'returns the last name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end

    context 'given a full name with a first name and no middle initial' do
      let(:name) { 'Author, Sally' }

      it 'returns the last name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end

    context 'given a full name with a first name and a middle initial' do
      let(:name) { 'Author, Sally A.' }

      it 'returns the last name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end

    context 'given a full name with a first name and a middle name' do
      let(:name) { 'Author, Sally Anne' }

      it 'returns the last name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end

    context 'given a full name with a first name and two middle initials' do
      let(:name) { 'Author, Sally A. B.' }

      it 'returns the last name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end

    context 'given a full name with a first name, middle initial, and suffix' do
      let(:name) { 'Author, Sally A., Jr.' }

      it 'returns the last name' do
        expect(wos_name.last_name).to eq 'Author'
      end
    end
  end

  describe '#first_initial' do
    context 'given only one name' do
      let(:name) { 'Author' }

      it 'returns nil' do
        expect(wos_name.first_initial).to eq nil
      end
    end

    context 'given a full name with a first initial and no middle name' do
      let(:name) { 'Author, S.' }

      it 'returns the first initial' do
        expect(wos_name.first_initial).to eq 'S'
      end
    end

    context 'given a full name with a first initial and a middle initial' do
      let(:name) { 'Author, S. A.' }

      it 'returns the first initial' do
        expect(wos_name.first_initial).to eq 'S'
      end
    end

    context 'given a full name with a first name and no middle initial' do
      let(:name) { 'Author, Sally' }

      it 'returns nil' do
        expect(wos_name.first_initial).to eq nil
      end
    end

    context 'given a full name with a first name and a middle initial' do
      let(:name) { 'Author, Sally A.' }

      it 'returns nil' do
        expect(wos_name.first_initial).to eq nil
      end
    end

    context 'given a full name with a first name and a middle name' do
      let(:name) { 'Author, Sally Anne' }

      it 'returns nil' do
        expect(wos_name.first_initial).to eq nil
      end
    end

    context 'given a full name with a first name and two middle initials' do
      let(:name) { 'Author, Sally A. B.' }

      it 'returns nil' do
        expect(wos_name.first_initial).to eq nil
      end
    end

    context 'given a full name with a first name, middle initial, and suffix' do
      let(:name) { 'Author, Sally A., Jr.' }

      it 'returns nil' do
        expect(wos_name.first_initial).to eq nil
      end
    end
  end

  describe '#middle_initial' do
    context 'given only one name' do
      let(:name) { 'Author' }

      it 'returns nil' do
        expect(wos_name.middle_initial).to eq nil
      end
    end

    context 'given a full name with a first initial and no middle name' do
      let(:name) { 'Author, S.' }

      it 'returns nil' do
        expect(wos_name.middle_initial).to eq nil
      end
    end

    context 'given a full name with a first initial and a middle initial' do
      let(:name) { 'Author, S. A.' }

      it 'returns the middle initial' do
        expect(wos_name.middle_initial).to eq 'A'
      end
    end

    context 'given a full name with a first name and no middle initial' do
      let(:name) { 'Author, Sally' }

      it 'returns nil' do
        expect(wos_name.middle_initial).to eq nil
      end
    end

    context 'given a full name with a first name and a middle initial' do
      let(:name) { 'Author, Sally A.' }

      it 'returns the middle initial' do
        expect(wos_name.middle_initial).to eq 'A'
      end
    end

    context 'given a full name with a first name and a middle name' do
      let(:name) { 'Author, Sally Anne' }

      it 'returns nil' do
        expect(wos_name.middle_initial).to eq nil
      end
    end

    context 'given a full name with a first name and two middle initials' do
      let(:name) { 'Author, Sally A. B.' }

      it 'returns the first of the middle initials' do
        expect(wos_name.middle_initial).to eq 'A'
      end
    end

    context 'given a full name with a first name, middle initial, and suffix' do
      let(:name) { 'Author, Sally A., Jr.' }

      it 'returns the middle initial' do
        expect(wos_name.middle_initial).to eq 'A'
      end
    end
  end
end
