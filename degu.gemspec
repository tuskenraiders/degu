# -*- encoding: utf-8 -*-
# stub: degu 0.9.1 ruby lib

Gem::Specification.new do |s|
  s.name = "degu".freeze
  s.version = "0.9.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "Library that includes enums, and rails support for enums and bitfield sets.".freeze
  s.email = "flori@ping.de".freeze
  s.extra_rdoc_files = ["README.md".freeze, "lib/degu.rb".freeze, "lib/degu/has_enum.rb".freeze, "lib/degu/has_set.rb".freeze, "lib/degu/init_active_record_plugins.rb".freeze, "lib/degu/polite.rb".freeze, "lib/degu/railtie.rb".freeze, "lib/degu/renum.rb".freeze, "lib/degu/renum/enumerated_value.rb".freeze, "lib/degu/renum/enumerated_value_type_factory.rb".freeze, "lib/degu/rude.rb".freeze, "lib/degu/version.rb".freeze]
  s.files = [".gitignore".freeze, ".travis.yml".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "VERSION".freeze, "degu.gemspec".freeze, "lib/degu.rb".freeze, "lib/degu/has_enum.rb".freeze, "lib/degu/has_set.rb".freeze, "lib/degu/init_active_record_plugins.rb".freeze, "lib/degu/polite.rb".freeze, "lib/degu/railtie.rb".freeze, "lib/degu/renum.rb".freeze, "lib/degu/renum/enumerated_value.rb".freeze, "lib/degu/renum/enumerated_value_type_factory.rb".freeze, "lib/degu/rude.rb".freeze, "lib/degu/version.rb".freeze, "spec/renum_spec.rb".freeze, "spec/spec_helper.rb".freeze, "test/has_enum_test.rb".freeze, "test/has_set_test.rb".freeze, "test/test_helper.rb".freeze, "test_helper.rb".freeze]
  s.homepage = "https://github.com/tuskenraiders/degu".freeze
  s.rdoc_options = ["--title".freeze, "Degu - Library for enums and bitfield sets.".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.6.9".freeze
  s.summary = "Library for enums and bitfield sets.".freeze
  s.test_files = ["test/has_enum_test.rb".freeze, "test/has_set_test.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.20".freeze])
  s.add_development_dependency(%q<test-unit>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<mocha>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<activerecord>.freeze, [">= 3.0".freeze, "< 9".freeze])
end
