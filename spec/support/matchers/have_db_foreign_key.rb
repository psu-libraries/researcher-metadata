# frozen_string_literal: true

RSpec::Matchers.define :have_db_foreign_key do |expected|
  match do |_actual|
    foreign_key_exists? && correct_name?
  end

  chain :with_name do |expected_name|
    @expected_name = expected_name
  end

  chain :to_table do |expected_to_table_name|
    @expected_to_table_name = expected_to_table_name.to_s
  end

  failure_message do
    m = "expected #{model_class} to #{description} (#{@error_details})"
    m
  end

  description do
    d = "have a foreign key contraint on #{expected}"
    d += " with name #{@expected_name}" if @expected_name.present?
    d
  end

  def foreign_key_exists?
    if !matched_foreign_key.nil?
      true
    else
      @error_details = "#{model_class} does not have a foreign key constraint on #{expected}"
      false
    end
  end

  def correct_name?
    return true if @expected_name.blank?

    if matched_key_name == @expected_name.to_s
      true
    else
      @error_details = "#{model_class} hasa foreign key constraint on #{expected}, " <<
        "named #{matched_key_name.inspect}, not #{@expected_name.inspect}"
      false
    end
  end

  def matched_foreign_key
    expected_class_name = expected.to_s.chomp('_id').classify
    expected_table_name = expected_class_name.tableize
    expected_column_name = expected_class_name.foreign_key

    foreign_keys.find { |fk| (fk.to_table == expected_table_name || fk.to_table == @expected_to_table_name) && fk.options[:column] == expected_column_name }
  end

  def matched_key_name
    matched_foreign_key.options[:name]
  rescue StandardError
    nil
  end

  def foreign_keys
    ::ActiveRecord::Base.connection.foreign_keys(table_name)
  end

  def model_class
    subject.class
  end

  def table_name
    model_class.table_name
  end
end
