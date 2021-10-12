# -*- encoding: utf-8 -*-
# stub: psu_identity 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "psu_identity".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Kiessling".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-10-12"
  s.description = "Gem for interfacing with psu's search-service".freeze
  s.email = ["ajkiessl@gmail.com".freeze]
  s.files = [".circleci/config.yml".freeze, ".gitignore".freeze, ".niftany/layout.yml".freeze, ".niftany/lint.yml".freeze, ".niftany/metrics.yml".freeze, ".niftany/naming.yml".freeze, ".niftany/niftany_rubocop_rspec.yml".freeze, ".niftany/performance.yml".freeze, ".niftany/style.yml".freeze, ".rspec".freeze, ".rubocop.yml".freeze, ".rubocop_todo.yml".freeze, ".ruby-version".freeze, "CODE_OF_CONDUCT.md".freeze, "Gemfile".freeze, "Gemfile.lock".freeze, "LICENSE.txt".freeze, "README.md".freeze, "Rakefile".freeze, "bin/console".freeze, "bin/setup".freeze, "lib/psu_identity.rb".freeze, "lib/psu_identity/search_service/atomic_link.rb".freeze, "lib/psu_identity/search_service/client.rb".freeze, "lib/psu_identity/search_service/person.rb".freeze, "lib/psu_identity/version.rb".freeze, "psu_identity.gemspec".freeze]
  s.homepage = "https://github.com/psu-libraries/psu_identity".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.3".freeze)
  s.rubygems_version = "3.2.20".freeze
  s.summary = "Gem for interfacing with psu's search-service".freeze

  s.installed_by_version = "3.2.20" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<faraday>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rake>.freeze, [">= 12.0"])
    s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<rspec-its>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.22"])
    s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.11"])
    s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2.5"])
    s.add_development_dependency(%q<simplecov>.freeze, ["= 0.17"])
    s.add_development_dependency(%q<vcr>.freeze, [">= 0"])
    s.add_development_dependency(%q<webmock>.freeze, [">= 0"])
  else
    s.add_dependency(%q<faraday>.freeze, ["~> 1.0"])
    s.add_dependency(%q<json>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 12.0"])
    s.add_dependency(%q<pry-byebug>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rspec-its>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 1.22"])
    s.add_dependency(%q<rubocop-performance>.freeze, ["~> 1.11"])
    s.add_dependency(%q<rubocop-rspec>.freeze, ["~> 2.5"])
    s.add_dependency(%q<simplecov>.freeze, ["= 0.17"])
    s.add_dependency(%q<vcr>.freeze, [">= 0"])
    s.add_dependency(%q<webmock>.freeze, [">= 0"])
  end
end
