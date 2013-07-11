# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "degu"
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = "2013-07-11"
  s.description = "Library that includes enums, and rails support for enums and bitfield sets."
  s.email = "dev@pkw.de"
  s.extra_rdoc_files = ["README.md", "lib/degu.rb", "lib/degu/has_enum.rb", "lib/degu/has_set.rb", "lib/degu/polite.rb", "lib/degu/renum.rb", "lib/degu/renum/enumerated_value.rb", "lib/degu/renum/enumerated_value_type_factory.rb", "lib/degu/rude.rb", "lib/degu/version.rb"]
  s.files = [".gitignore", ".travis.yml", "COPYING", "Gemfile", "README.md", "Rakefile", "VERSION", "degu.gemspec", "lib/degu.rb", "lib/degu/has_enum.rb", "lib/degu/has_set.rb", "lib/degu/polite.rb", "lib/degu/renum.rb", "lib/degu/renum/enumerated_value.rb", "lib/degu/renum/enumerated_value_type_factory.rb", "lib/degu/rude.rb", "lib/degu/version.rb", "spec/renum_spec.rb", "spec/spec_helper.rb", "test/has_enum_test.rb", "test/has_set_test.rb", "test/test_helper.rb", "test_helper.rb"]
  s.homepage = "https://github.com/tuskenraiders/degu"
  s.rdoc_options = ["--title", "Degu - Library for enums and bitfield sets.", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.4"
  s.summary = "Library for enums and bitfield sets."
  s.test_files = ["test/has_enum_test.rb", "test/has_set_test.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<gem_hadar>, ["~> 0.1.8"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<utils>, [">= 0"])
      s.add_runtime_dependency(%q<activerecord>, ["< 5.0", ">= 3.0"])
    else
      s.add_dependency(%q<gem_hadar>, ["~> 0.1.8"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<utils>, [">= 0"])
      s.add_dependency(%q<activerecord>, ["< 5.0", ">= 3.0"])
    end
  else
    s.add_dependency(%q<gem_hadar>, ["~> 0.1.8"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<utils>, [">= 0"])
    s.add_dependency(%q<activerecord>, ["< 5.0", ">= 3.0"])
  end
end
