# vim: set filetype=ruby et sw=2 ts=2:

require 'rspec'
require 'gem_hadar'

GemHadar do
  name        'degu'
  author      'Florian Frank'
  email       'dev@pkw.de'
  homepage    "https://github.com/tuskenraiders/#{name}"
  summary     'Library for enums and bitfield sets.'
  description 'Library that includes enums, and rails support for enums and bitfield sets.'
  test_dir    'test'
  test_files  Dir['test/**/*_test.rb']
  spec_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.rvmrc', 'coverage', '.DS_Store', '.ruby-gemset', '.ruby-version'
  readme      'README.rdoc'

  dependency  'activerecord', '>= 3.0', '< 5.0'

  development_dependency 'mocha'
  development_dependency 'sqlite3'
  development_dependency 'rspec'
  development_dependency 'utils'
end

desc 'Run specs and tests'
task :default => [ :test, :spec ]
