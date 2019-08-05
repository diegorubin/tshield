# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'tshield/version'

Gem::Specification.new do |s|
  s.name        = 'tshield'
  s.version     = TShield::Version
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.summary     = 'Proxy for mocks API responses'
  s.email       = 'rubin.diego@gmail.com'
  s.homepage    = 'https://github.com/diegorubin/tshield'
  s.description = 'Proxy for mocks API responses'
  s.authors     = ['Diego Rubin']

  s.files = Dir['{app,config,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.files += %w[Gemfile README.md]
  s.files << 'tshield.gemspec'

  s.executables << 'tshield'

  s.test_files = Dir['spec/**/*']

  s.required_ruby_version = '>= 2.3'

  s.add_dependency('byebug', '~> 11.0', '>= 11.0.1')
  s.add_dependency('haml', '~> 4.0', '>= 4.0.7')
  s.add_dependency('httparty', '~> 0.14', '>= 0.14.0')
  s.add_dependency('json', '~> 2.0', '>= 2.0')
  s.add_dependency('sinatra', '~> 1.4', '>= 1.4.0')
  s.add_development_dependency('cucumber', '~> 3.1', '>= 3.1.2')
  s.add_development_dependency('rake', '~> 10.0', '>= 10.0')
  s.add_development_dependency('rdoc', '~> 6.0', '>= 6.0')
  s.add_development_dependency('reek', '~> 5.4.0', '>= 5.4.0')
  s.add_development_dependency('rspec', '~> 3.5', '>= 3.5.0')
  s.add_development_dependency('rubocop', '~> 0.73.0', '>= 0.73.0')
  s.add_development_dependency('rubocop-rails', '~> 2.2.0', '>= 2.2.1')
  s.add_development_dependency('simplecov', '~> 0.12', '>= 0.12.0')
  s.add_development_dependency('webmock', '~> 2.1', '>= 2.1.0')
end
