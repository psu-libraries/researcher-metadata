require 'nokogiri'

class NSFGrantImporter
  def initialize(dirname:)
    @dirname = dirname
  end

  def call
    import_files = Dir.children(dirname).select { |f| File.extname(f) == '.xml' }
    pbar = ProgressBar.create(title: 'Importing NSF Grant Data', total: import_files.count) unless Rails.env.test?
    import_files.each do |file|
      nsf_grant = NSFGrant.new(File.open(dirname.join(file)) { |f| Nokogiri::XML(f) })

      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  private

  attr_reader :dirname
end
