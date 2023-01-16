# -*- encoding: utf-8 -*-
# stub: apivore 1.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "apivore".freeze
  s.version = "1.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Charles Horn".freeze]
  s.date = "2023-01-16"
  s.description = "Tests your rails API using its OpenAPI (Swagger) description of end-points, models, and query parameters.".freeze
  s.email = "charles.horn@gmail.com".freeze
  s.files = ["data/custom_schemata/westfield_api_standards.json".freeze, "data/draft04_schema.json".freeze, "data/swagger_2.0_schema.json".freeze, "lib/apivore.rb".freeze, "lib/apivore/all_routes_tested_validator.rb".freeze, "lib/apivore/custom_schema_validator.rb".freeze, "lib/apivore/fragment.rb".freeze, "lib/apivore/rails_shim.rb".freeze, "lib/apivore/rspec_helpers.rb".freeze, "lib/apivore/rspec_matchers.rb".freeze, "lib/apivore/swagger.rb".freeze, "lib/apivore/swagger_checker.rb".freeze, "lib/apivore/validator.rb".freeze, "lib/apivore/version.rb".freeze]
  s.homepage = "http://github.com/westfieldlabs/apivore".freeze
  s.licenses = ["Apache 2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "Tests your API against its OpenAPI (Swagger) 2.0 spec".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<json-schema>.freeze, ["~> 2.5"])
    s.add_runtime_dependency(%q<rspec>.freeze, ["~> 3"])
    s.add_runtime_dependency(%q<rspec-expectations>.freeze, ["~> 3.1"])
    s.add_runtime_dependency(%q<rspec-mocks>.freeze, ["~> 3.1"])
    s.add_runtime_dependency(%q<hashie>.freeze, ["~> 3.3"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.3"])
    s.add_development_dependency(%q<rspec-rails>.freeze, ["~> 3"])
    s.add_runtime_dependency(%q<actionpack>.freeze, [">= 5", "< 7"])
    s.add_development_dependency(%q<activesupport>.freeze, [">= 5", "< 7"])
    s.add_development_dependency(%q<test-unit>.freeze, ["~> 3"])
  else
    s.add_dependency(%q<json-schema>.freeze, ["~> 2.5"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3"])
    s.add_dependency(%q<rspec-expectations>.freeze, ["~> 3.1"])
    s.add_dependency(%q<rspec-mocks>.freeze, ["~> 3.1"])
    s.add_dependency(%q<hashie>.freeze, ["~> 3.3"])
    s.add_dependency(%q<pry>.freeze, ["~> 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.3"])
    s.add_dependency(%q<rspec-rails>.freeze, ["~> 3"])
    s.add_dependency(%q<actionpack>.freeze, [">= 5", "< 7"])
    s.add_dependency(%q<activesupport>.freeze, [">= 5", "< 7"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 3"])
  end
end
