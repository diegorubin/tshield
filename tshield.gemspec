# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tshield/version"

Gem::Specification.new do |s|
  s.name        = "tshield"
  s.version     = TShield::Version
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ["MIT"]
  s.summary     = "Proxy for mocks API responses"
  s.email       = "rubin.diego@gmail.com"
  s.homepage    = "https://github.com/diegorubin/tshield"
  s.description = "Proxy for mocks API responses"
  s.authors     = ['Diego Rubin']

  s.files = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.files += %w(Gemfile README.md)
  s.files << "tshield.gemspec"

  s.executables << 'tshield'

  s.test_files = Dir["spec/**/*"]

  s.add_dependency("httparty", "~> 0.14", ">= 0.14.0")
  s.add_dependency("sinatra", "~> 1.4", ">= 1.4.0")
  s.add_dependency("json", "~> 2.0", ">= 2.0")
  s.add_dependency("byebug", "~> 9.0", ">= 9.0.0")
  s.add_dependency("haml", "~> 4.0", ">= 4.0.7")
  s.add_development_dependency("rspec", "~> 3.5", ">= 3.5.0")
  s.add_development_dependency("webmock", "~> 2.1", ">= 2.1.0")
  s.add_development_dependency("simplecov", "~> 0.12", ">= 0.12.0")
end

