class UserAnalyzer

  attr_accessor :filename,
                :fatal_errors,
                :batch_size,
                :missing_users

  def initialize(filename:, batch_size: 500)
    @fatal_errors = []
    @filename = filename
    @fatal_errors << "Cannot find file #{filename.inspect}" unless File.exists?( filename )
    @fatal_errors << "File is empty #{filename.inspect}" if File.zero?( filename )
    @fatal_errors << "File has no records #{filename.inspect}" unless File.new(filename).readlines.size > 1
    @batch_size = batch_size
    @missing_users = {}
  end

  def call
    pbar = ProgressBar.create(title: 'Importing CSV', total: line_count) unless Rails.env.test?
    chunk_number = 0
    SmarterCSV.process(filename, chunk_size: batch_size, headers_in_file: true, file_encoding: encoding) do |chunk|
     #objects = []
      chunk.each_with_index.map do |row, index|
        pbar.increment unless Rails.env.test?
        row_number = (chunk_number * batch_size) + index + 1
        begin
         row_to_object(row)
         #object = row_to_object(row)
         #if object
         #  object.validate!
         #  objects << object
         #end
        rescue => e
          add_error(message: e.message, row_number: row_number)
        end
      end
     #bulk_import(objects)
      chunk_number += 1
    end
    pbar.finish unless Rails.env.test?
    puts missing_users.to_yaml
    puts ">>>>>>>>>>>>>>>>  MISSING USERS COUNT: #{missing_users.count}"
    raise ParseError, fatal_errors if fatal_errors_encountered?

    # Output results to a CSV file
    CSV.open("/Users/chet/wa/src/psu-research-metadata/db/data/missing_huck_users.csv", "wb") do |csv|
      csv << ["webaccess_id", "name", "person_type", "position_type", "job_title"]
     #csv << ["webaccess_id", "name", "person_type", "job_title"]
      missing_users.each do |k,v|
        webaccess_id = k
        name = v[:name]
        person_type = v[:person_type]
        position_type = v[:position_type]
        job_title = v[:job_title]
        csv << [webaccess_id, name, person_type, position_type, job_title]
       #csv << [webaccess_id, name, person_type, job_title]
      end
    end
  end

  def row_to_object(row)

    webaccess_id = row[:webaccess_id].downcase
    name = row[:name]
    job_title = row[:job_title]
    person_type = row[:person_type]
    position_type = row[:position_type]

    existing_user = User.find_by(webaccess_id: webaccess_id)

    if existing_user
    else
      missing_users[webaccess_id] = {
        :name => name,
        :job_title => job_title,
        :person_type => person_type,
        :position_type => position_type
      }
    end
  end

  def bulk_import(objects)
  end

  private

  def fatal_errors_encountered?
    fatal_errors.length > 0
  end

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
