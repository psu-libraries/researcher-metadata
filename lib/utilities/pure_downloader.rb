# frozen_string_literal: true

require 'json'
require 'pathname'
require 'io/console'

class PureDownloader
  def download_pure_orgs
    get_api_key

    first_org_result = `curl -X GET --header 'Accept: application/json' --header 'api-key: #{api_key}' 'https://pennstate.pure.elsevier.com/ws/api/520/organisational-units?navigationLink=false&size=1&offset=0'`

    total_orgs = JSON.parse(first_org_result)['count']

    all_orgs_results = `curl -X GET --header 'Accept: application/json' --header 'api-key: #{api_key}' 'https://pennstate.pure.elsevier.com/ws/api/520/organisational-units?navigationLink=false&size=#{total_orgs}&offset=0'`

    File.open(org_data_file, 'w') do |f|
      f.puts all_orgs_results
    end
  end

  def download_pure_users
    get_api_key

    first_person_result = `curl -X GET --header 'Accept: application/json' --header 'api-key: #{api_key}' 'https://pennstate.pure.elsevier.com/ws/api/520/persons?navigationLink=false&size=1&offset=0'`

    total_persons = JSON.parse(first_person_result)['count']

    all_persons_results = `curl -X GET --header 'Accept: application/json' --header 'api-key: #{api_key}' 'https://pennstate.pure.elsevier.com/ws/api/520/persons?navigationLink=false&size=#{total_persons}&offset=0'`

    File.open(user_data_file, 'w') do |f|
      f.puts all_persons_results
    end
  end

  def download_pure_pubs
    get_api_key

    first_pub_result = `curl -X GET --header 'Accept: application/json' --header 'api-key: #{api_key}' 'https://pennstate.pure.elsevier.com/ws/api/520/research-outputs?navigationLink=false&size=1&offset=0'`

    page_size = 1000
    total_pubs = JSON.parse(first_pub_result)['count']

    total_pages = (total_pubs / page_size.to_f).ceil

    1.upto(total_pages) do |i|
      offset = (i - 1) * page_size
      pubs = `curl -X GET --header 'Accept: application/json' --header 'api-key: #{api_key}' 'https://pennstate.pure.elsevier.com/ws/api/520/research-outputs?navigationLink=false&size=#{page_size}&offset=#{offset}'`
      download_file = pure_pub_dir.join("pure_publications_#{i}.json")
      File.open(download_file, 'w') do |f|
        f.puts pubs
      end
    end
  end

  def download_pure_fingerprints
    get_api_key

    first_fingerprint_result = `curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'api-key: #{api_key}' -d '{"size": 1, "offset": 0, "renderings": ["fingerprint"] }' 'https://pennstate.pure.elsevier.com/ws/api/520/research-outputs'`

    total_fingerprints = JSON.parse(first_fingerprint_result)['count']

    all_fingerprints_results = `curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'api-key: #{api_key}' -d '{"size": #{total_fingerprints}, "offset": 0, "renderings": ["fingerprint"] }' 'https://pennstate.pure.elsevier.com/ws/api/520/research-outputs'`

    File.open(fingerprint_data_file, 'w') do |f|
      f.puts all_fingerprints_results
    end
  end

  def data_dir
    root_dir.join('db', 'data')
  end

  def pure_pub_dir
    data_dir.join('pure_publications')
  end

  def user_data_file
    data_dir.join('pure_users.json')
  end

  def org_data_file
    data_dir.join('pure_organizations.json')
  end

  def fingerprint_data_file
    data_dir.join('pure_publication_fingerprints.json')
  end

  private

    attr_reader :api_key

    def get_api_key
      print 'Enter Pure API key:  '
      @api_key = $stdin.noecho(&:gets).chomp

      puts "\n"
    end

    def root_dir
      Pathname.new(File.expand_path("#{File.dirname(__FILE__)}/../.."))
    end
end
