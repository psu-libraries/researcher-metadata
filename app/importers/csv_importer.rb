# frozen_string_literal: true

class CSVImporter
  class ParseError < RuntimeError; end

  attr_accessor :filename,
                :fatal_errors,
                :batch_size

  def initialize(filename:, batch_size: 500)
    @fatal_errors = []
    @filename = filename
    @fatal_errors << "Cannot find file #{filename.inspect}" unless File.exists?(filename)
    @fatal_errors << "File is empty #{filename.inspect}" if File.zero?(filename)
    @fatal_errors << "File has no records #{filename.inspect}" unless File.new(filename).readlines.size > 1
    @batch_size = batch_size
  end

  def call
    pbar = ProgressBar.create(title: 'Importing CSV', total: line_count) unless Rails.env.test?
    chunk_number = 0
    SmarterCSV.process(filename, chunk_size: batch_size, headers_in_file: true, file_encoding: encoding) do |chunk|
      objects = []
      chunk.each_with_index.map do |row, index|
        pbar.increment unless Rails.env.test?
        row_number = (chunk_number * batch_size) + index + 1
        begin
          object = row_to_object(row)
          if object
            object.validate!
            objects << object
          end
        rescue StandardError => e
          add_error(message: e.message, row_number: row_number)
        end
      end
      bulk_import(objects)
      chunk_number += 1
    end
    pbar.finish unless Rails.env.test?
    raise ParseError, fatal_errors if fatal_errors_encountered?
  end

  def row_to_object(row)
    # Defined in parent class
    raise NotImplementedError
  end

  def bulk_import(objects)
    # Defined in parent class
    raise NotImplementedError
  end

  def fatal_errors_encountered?
    fatal_errors.length.positive?
  end

  private

    def add_error(message:, row_number:)
      fatal_errors << "Line #{row_number}: #{message}"
    end

    def line_count
      `wc -l #{filename}`.to_i - 1
    end

    def encoding
      'utf-8'
    end
end
