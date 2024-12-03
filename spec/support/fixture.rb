# frozen_string_literal: true

def fixture_path(name)
  ROOT.join('spec', 'fixtures', name)
end

def fixture_file_open(filename)
  File.open(fixture_path(filename))
end

def fixture_file_upload(filename, mime_type)
  Rack::Test::UploadedFile.new(fixture_path(filename), mime_type)
end

def store_fixture_file(uploader, filename)
  uploader.store!(
    File.open(
      fixture_path(filename)
    )
  )
end
