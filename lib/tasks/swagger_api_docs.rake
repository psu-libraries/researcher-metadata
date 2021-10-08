# frozen_string_literal: true

namespace :swagger_api_docs do
  desc 'Generate Swagger API Docs JSON'
  task :generate_json_file, [:version] => :environment do |_task, args|
    args.with_defaults(version: 'v1')
    swagger_data = Swagger::Blocks.build_root_json(SwaggeredClasses.all)
    File.open(
      swagger_api_docs_json_file(args.version), 'w'
    ) { |file| file.write(swagger_data.to_json) }
  end
end

def swagger_api_docs_json_file(version)
  Rails.root.join('public', 'api_docs', 'swagger_docs', version, 'swagger.json')
end
